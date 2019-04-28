@lazyglobal off.
RunOncePath("0:/utilities/constants").

function EstimateCd {
  local start_time is time.
  local v0 is ship:velocity:surface.
  local r0 is ship:body:position.

  local pressure is CalcPressure(ship:body, r0).
  local density is CalcDensityQ(ship:q, ship:velocity:surface).

  local grav_acc is (ship:body:mu *  r0:normalized) / (r0:mag) ^ 2.
  local thrust_acc is ship:availableThrust * ship:facing:foreVector / ship:mass.

  wait 0.
  local v1 is ship:velocity:surface.
  local dt is (time - start_time):seconds.  

  local dv is v1 - v0.
  local dv_drag is dv - (grav_acc + thrust_acc) * dt. 
  if density = 0 {
    return 0.
  }
  return 2 * ship:mass * dv_drag:mag / (density * v0:mag^2 * dt).
}


function DynamicPressure {
  parameter
    v_vec,
    density.

  return (density * v_vec:mag ^ 2) / 2.
}

function DynamicPressureMShip {
  local pressure is CalcPressure(ship:body, ship:body:position).
  local density is CalcDensityQ(ship:q, ship:velocity:surface).
  local gamma is Adiabatic_Index[ship:body:name].
  local mach_number is ship:velocity:surface:mag / SpeedOfSound(gamma, pressure, density).

  return DynamicPressure(gamma, mach_number, pressure).
}

function DynamicPressureM {
  parameter
    gamma,
    mach_number,
    pressure.

  return (gamma * pressure * mach_number^2) / 2.
}

function CalcDensityQ {
  parameter
    q,
    v_vec.

  return 2 * q * constant:ATMtokPa * 1e3 / v_vec:sqrMagnitude.
}

function CalcDensity {
  parameter
    pressure,
    molar_mass,
    temperature.

  return (pressure * molar_mass) / (Ideal_Gas_Constant * temperature).
}

function CalcDensityShip {
  
  local pressure is CalcPressure(ship:body, ship:body:position).
  local molar_mass is Molecular_Mass[ship:body:name].
  local temperature is Average_Temperature[ship:body:name].

  return CalcDensity(pressure, molar_mass, temperature).
}

function SpeedOfSoundShip {
  local pressure is CalcPressure(ship:body, ship:body:position).
  local density is CalcDensity(pressure, Molecular_Mass[ship:body:name], ship:sensors:temp).
  return SpeedOfSound(Adiabatic_Index[ship:body:name], pressure, density).
}

function SpeedOfSound {
  parameter
    gamma,
    pressure,
    density.

  return sqrt(gamma * pressure / density).
}

function CalcPressure {
  parameter
    curr_body,
    r_vec.

  local altitude is r_vec:mag - curr_body:radius.
  if altitude < 0 or altitude > curr_body:atm:height {
    return 0.
  }

  return body:atm:altitudePressure(altitude) * constant:AtmToKPa * 1e3.
}

function localG {
  parameter
    curr_ship.

  return curr_ship:body:mu / curr_ship:body:position:mag ^ 2.
}
