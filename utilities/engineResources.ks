@lazyglobal off.
RunOncePath("./math/newton.ks").

local Liquid is "LiquidFuel".
local Oxidizer is "Oxidizer".
local Solid is "SolidFuel".
local Xenon is "XenonGas".
local MonoProp is "MonoPropellant".

local EngLiquid is "liquid".
local EngNuclear is "nuclear".
local EngSolid is "solid".
local EngIon is "ion".

local LiquidMass is 5.
local OxidizerMass is 5.
local MonoPropMass is 4.
local XenonMass is 0.1.
local SolidMass is 7.5.

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

function ResourceUsage {
  local resource_usage is lexicon().
  resource_usage:add(Liquid, 0).
  resource_usage:add(Oxidizer, 0).
  resource_usage:add(Solid, 0).
  resource_usage:add(Xenon, 0).
  resource_usage:add(MonoProp, 0).

  return resource_usage.
}

function EngineResources {
  parameter
    ship.
  
  local lock resources to stage:resourceslex.  
  local engines_ is List().
  local ship_ is ship.

  local stage_ship_ is {
    parameter
      update_status_func.

    stage.
    update_status_func("Staging.. stage " + stage:number).
    set engines_ to update_engines_().
    return engines_.
  }.

  local update_engines_ is {
    local temp is 0.
    List engines in temp.
    return temp.
  }.

  local usage is {
    local resource_usage is ResourceUsage().
    local eng_types is group_by(engines_, EngineType@).

    for type in eng_types:keys {
      local total_resources is reduce(
        eng_types[type],
        {parameter sum, eng. return sum + eng:fuelFlow. }
      ).

      if type = EngLiquid {
        set resource_usage[Liquid] to resource_usage[Liquid] + 0.45 * total_resources.
        set resource_usage[Oxidizer] to resource_usage[Oxidizer] + 0.55 * total_resources.
      }
      if type = EngNuclear {
        set resource_usage[Liquid] to resource_usage[Liquid] + total_resources.
      }
      if type = EngSolid {
        set resource_usage[Solid] to resource_usage[Solid] + total_resources.
      }
      if type = EngIon {
        set resource_usage[Xenon] to resource_usage[Xenon] + total_resources.
      }
    }

    return resource_usage.
  }.
  
  local estimate_mass_rate is {
    parameter
      resource_usage is usage().

    local mass_rate is 0.

    set mass_rate to mass_rate - resource_usage[Liquid] * LiquidMass.
    set mass_rate to mass_rate - resource_usage[Oxidizer] * OxidizerMass. 
    set mass_rate to mass_rate - resource_usage[Solid] * SolidMass. 
    set mass_rate to mass_rate - resource_usage[Xenon] * XenonMass. 
    set mass_rate to mass_rate - resource_usage[MonoProp] * MonoPropMass. 
    set mass_rate to mass_rate / 1000.

    return mass_rate.
  }.

  local estimate_burn is {
    parameter
      delta_v_vec,
      v_vec,
      mass_rate is estimate_mass_rate().

    local burn_angle is VAng(delta_v_vec, v_vec).
    
    if mass_rate <> 0 {
      if burn_angle < 10 {
        return colinear_burn(v_vec + delta_v_vec, v_vec, mass_rate, ship_:availableThrust).
      }
      if burn_angle > 170 {
        return colinear_burn(v_vec + delta_v_vec, v_vec, mass_rate, -ship_:availableThrust).
      }
    }

    return simple_burn(delta_v_vec:mag, 0, ship_:availableThrust).
  }.

  local colinear_burn is {
    parameter
      v_f,
      v_0,
      mass_rate,
      F.

    local t is estimate_burn_time(v_f - v_0, mass_rate, F).
    local c is mass_rate * t.    

    local mass_0 is ship_:mass.
    local delta_mass is mass_rate * t.
    local final_mass is ship_:mass + delta_mass.

    local acceration_term is F * (final_mass * ln(final_mass) - delta_mass - (mass_0 * ln(mass_0))) / mass_rate^2.
    local initial_value_term is (v_0 - F * ln(mass_0) / mass_rate) * t.
    local dr is acceration_term + initial_value_term.

    local point_dr is {
      parameter
        t_start.

      return dr - (v_0 * t_start + v_f * (t - t_start)).
    }.

    local point_dr_prime is {
      parameter
        t_start.

      return v_f - v_0.
    }.

    local results is list().
    results:add(t).
    results:add(Newton(point_dr, point_dr_prime, t / 2)).
  }.

  local simple_burn is {
    parameter
      v_f,
      v_0,
      F.

    local results is list().
    local t is estimate_burn_time(v_f - v_0, 0, F).
    results:add(t).
    results:add(t / 2).
  }.

  local estimate_burn_time is {
    parameter
      delta_v,
      mass_rate is estimate_mass_rate(),
      F is ship_:availableThrust.

    if mass_rate <> 0 {
      return colinear_burn_time(delta_v:mag, mass_rate).
    } 
    
    return delta_v * ship_:mass / F.
  }.

  local colinear_burn_time is {
    parameter
      delta_v,
      mass_rate.

    local exponent is mass_rate / ship_:maxThrust * (delta_v + ship_:maxThrust * ln(ship_:mass) / mass_rate).
    local t is (constant:e^exponent) / mass_rate - ship_:mass / mass_rate.

    return t.
  }.

  local update_stage is {
    parameter
      update_status_func is { parameter message. }.

    if stage:number = 0 {
      return engines_.
    }

    if not stage:ready {
      return engines_.
    }

    if ship:maxthrust = 0 {
      return stage_ship_(update_status_func).
    }

    if any(engines_, { parameter engine. return engine:flameout. }) {
      return stage_ship_(update_status_func).
    }

    return engines_.
  }.

  local instance is lexicon().

  set engines_ to update_engines_().

  instance:add("usage", usage@).
  instance:add("update_stage", update_stage@).
  instance:add("resources", stage:resourcesLex@).
  instance:add("mass_rate", estimate_mass_rate@).
  instance:add("estimate_burn", estimate_burn@).
  instance:add("burn_time", estimate_burn_time@).

  return instance.
}