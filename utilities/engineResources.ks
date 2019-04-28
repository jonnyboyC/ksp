@lazyglobal off.
RunOncePath("0:/math/newton.ks").
RunOncePath("0:/utilities/fp.ks").

// fuel types
local Liquid is "LiquidFuel".
local Oxidizer is "Oxidizer".
local Solid is "SolidFuel".
local Xenon is "XenonGas".
local MonoProp is "MonoPropellant".

// engine types
local EngLiquid is "liquid".
local EngNuclear is "nuclear".
local EngSolid is "solid".
local EngIon is "ion".

// fuel densities
local LiquidMass is 5.
local OxidizerMass is 5.
local MonoPropMass is 4.
local XenonMass is 0.1.
local SolidMass is 7.5.

// determine the propelent type of a given engine
function EngineType {
  parameter
    engine.

  local name is engine:name.
  if name:contains(EngSolid) {
    return EngSolid.
  }
  if name:contains(EngLiquid) {
    return EngLiquid.
  }
  if name:contains(EngNuclear) {
    return EngNuclear.
  }
  if name:contains(EngIon) {
    return EngIon.
  }

  return "other".
}

// create resource usage lexicon
function ResourceUsage {
  local resource_usage is lexicon().
  resource_usage:add(Liquid, 0).
  resource_usage:add(Oxidizer, 0).
  resource_usage:add(Solid, 0).
  resource_usage:add(Xenon, 0).
  resource_usage:add(MonoProp, 0).

  return resource_usage.
}

// create engine resource helper
function EngineResources {
  parameter
    curr_ship. // ship to determine for
  
  // local lock resources to stage:resourceslex.  
  local engines_ is List().
  local ship_ is curr_ship.

  local stage_ship_ is {
    parameter
      update_status_func.

    stage.
    update_status_func("Staging.. stage " + stage:number).
    set engines_ to update_engines_().
    return engines_.
  }.

  // update engines with new engine list
  local function update_engines_ {
    local temp is 0.
    List engines in temp.
    return temp.
  }.

  // determine current engine usage
  local function usage {

    // get usage lexicon
    local resource_usage is ResourceUsage().

    // group engines by type
    local eng_types is group_by(engines_, EngineType@).

    // for each engine type determine overall usage
    for type in eng_types:keys {

      // get fuel flow rate for each engine of a given type
      local total_resources is reduce(
        eng_types[type],
        {parameter sum, eng. return sum + eng:fuelFlow. }
      ).

      // switch based on type
      if type = EngLiquid {
        set resource_usage[Liquid] to resource_usage[Liquid] + 0.45 * total_resources.
        set resource_usage[Oxidizer] to resource_usage[Oxidizer] + 0.55 * total_resources.
      }
      else if type = EngNuclear {
        set resource_usage[Liquid] to resource_usage[Liquid] + total_resources.
      }
      else if type = EngSolid {
        set resource_usage[Solid] to resource_usage[Solid] + total_resources.
      }
      else if type = EngIon {
        set resource_usage[Xenon] to resource_usage[Xenon] + total_resources.
      }
    }

    // return current usage
    return resource_usage.
  }.
  
  // estimate fuel mass rate use
  local function estimate_mass_rate {
    parameter
      resource_usage is usage().

    local mass_rate is 0.

    // break usage by type and multiply by density
    set mass_rate to mass_rate - resource_usage[Liquid] * LiquidMass.
    set mass_rate to mass_rate - resource_usage[Oxidizer] * OxidizerMass. 
    set mass_rate to mass_rate - resource_usage[Solid] * SolidMass. 
    set mass_rate to mass_rate - resource_usage[Xenon] * XenonMass. 
    set mass_rate to mass_rate - resource_usage[MonoProp] * MonoPropMass. 

    // grams to kg
    set mass_rate to mass_rate / 1000.

    return mass_rate.
  }.

  // estimate burn
  local function estimate_burn {
    parameter
      v_vec_f,      // final velocity vector
      v_vec_0,      // intial veclotiy vector 
      mass_rate is estimate_mass_rate().


    local delta_v_vec is v_vec_f - v_vec_0.
    local burn_angle is VAng(delta_v_vec, v_vec_0).
    
    if mass_rate <> 0 {
      local v_f is v_vec_f:mag.
      local v_o is v_vec_0:mag.

      if burn_angle < 10 {
        return colinear_burn(v_f, v_o, mass_rate, ship_:availableThrust).
      }
      if burn_angle > 170 {
        return colinear_burn(v_f, v_o, mass_rate, -ship_:availableThrust).
      }
    }

    return simple_burn(delta_v_vec:mag, 0, ship_:availableThrust).
  }.

  // estimate a burn that is aligned with the current velocity vector
  local function colinear_burn {
    parameter
      v_f,        // final velocity mag
      v_0,        // initial velocity mag
      mass_rate,  // mass rate
      F.          // ship thrust

    // get initial time estimate
    local t is estimate_burn_time(v_f - v_0, mass_rate, F).
    local c is mass_rate * t.    

    // get boundary conditions
    local mass_0 is ship_:mass.
    local delta_mass is mass_rate * t.
    local final_mass is ship_:mass + delta_mass.

    // TODO figure this out again
    local acceration_term is F * (final_mass * ln(final_mass) - delta_mass - (mass_0 * ln(mass_0))) / mass_rate^2.
    local initial_value_term is (v_0 - F * ln(mass_0) / mass_rate) * t.
    local dr is acceration_term + initial_value_term.

    // delta radius
    local point_dr is {
      parameter
        t_start.

      return dr - (v_0 * t_start + v_f * (t - t_start)).
    }.

    // delta radius derivative
    local point_dr_prime is {
      parameter
        t_start.

      return v_f - v_0.
    }.

    // use newton method to determine start time
    local results is lexicon().
    results:add("time", t).
    results:add("start", Newton(point_dr, point_dr_prime, t / 2)).    
    return results.
  }.

  // simple method to determine burn time
  // this assumes no mass loss
  local function simple_burn {
    parameter
      v_f,
      v_0,
      F.

    local t is estimate_burn_time(v_f - v_0, 0, F).

    local results is lexicon().
    results:add("time", t).
    results:add("start", t / 2).
    return results.
  }.

  // estimate burn time
  local function estimate_burn_time {
    parameter
      delta_v,  // delta v
      mass_rate is estimate_mass_rate(),
      F is ship_:availableThrust.

    // if we have an estimate for mass rate use more accurate method
    if mass_rate <> 0 {
      return colinear_burn_time(delta_v, mass_rate).
    } 
    
    // else simple method
    return delta_v * ship_:mass / F.
  }.

  // estimate burn time when burn is essentially aligned with current velocity
  local function colinear_burn_time {
    parameter
      delta_v,   // delta v
      mass_rate. // current mass rate

    local exponent is mass_rate / ship_:maxThrust * (delta_v + ship_:maxThrust * ln(ship_:mass) / mass_rate).
    local t is (constant:e^exponent) / mass_rate - ship_:mass / mass_rate.

    return t.
  }.

  // update stage helper
  local update_stage is {
    parameter
      update_status_func is { parameter message. }.

    // if we're on the final stage we can no longer stage
    if stage:number = 0 {
      return engines_.
    }

    // if we can't stage don't try to
    if not stage:ready {
      return engines_.
    }

    // if our ships current max thrust is 0 stage
    if ship:maxthrust = 0 {
      return stage_ship_(update_status_func).
    }

    // if any engines have flamed out stage
    if any(engines_, { parameter engine. return engine:flameout. }) {
      return stage_ship_(update_status_func).
    }

    return engines_.
  }.

  set engines_ to update_engines_().

  local instance is lexicon().
  instance:add("usage", usage@).
  instance:add("update_stage", update_stage@).
  instance:add("resources", stage:resourcesLex@).
  instance:add("mass_rate", estimate_mass_rate@).
  instance:add("estimate_burn", estimate_burn@).
  instance:add("burn_time", estimate_burn_time@).

  return instance.
}