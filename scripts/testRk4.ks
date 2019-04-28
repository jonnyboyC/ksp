@lazyglobal off.
RunOncePath("0:/math/rungeKutta.ks").
RunOncePath("0:/flightParameters/otherParameters.ks").
RunOncePath("0:/utilities/constants.ks").

// debug cosine function
local cosine is {
  parameter
    x,
    t.

  local temp is 360 / 24 * t.
  local dx is list().
  local dx0 is cos(temp).
  print "x: " + x[0] + ", dx: " + dx0.

  dx:add(dx0).

  return dx.
}.

// 
local harmonic is {
  parameter
    x,
    t.

  local k is 2.
  local m is 1.
  local dx is list().

  dx:add(x[1]).
  dx:add(-k / m * x[0]).
  return dx.
}.

local decend is {
  parameter
    x,
    t.

  local dx is list().
  local Cd is 0.001.
  dx:add(x[1]).

  local pos is x[0].
  local vel is x[1].

  local gravity_acc is -(ship:body:mu * pos:normalized) / (pos:mag) ^ 2.
  local pressure is CalcPressure(ship:body, pos).
  local density is CalcDensity(pressure, Molecular_Mass[ship:body:name], ship:sensors:temp).
  local drag_acc is -density * Cd * (vel:mag)^2 * vel:normalized / (2 * ship:mass).
  local thrust_acc is -ship:maxThrust * vel:normalized / ship:mass .

  //dx:add(gravity_acc).
  // dx:add(gravity_acc + drag_acc).
  print(
    "p: " + round(pressure, 3) + 
    " rho: " + round(density, 3) + 
    " r: " + round(pos:mag, 3) + 
    " v: " + round(vel:mag, 3)
  ).
  dx:add(gravity_acc + drag_acc + thrust_acc).
  return dx.
}.

local x0 is list().
x0:add(V(700_000, 0, 0)).
x0:add(V(0, 1900, 0)).

local values is RungeKutta(x0, 1, 600, decend).

print VCrs(x0[0], x0[1]):mag.
print VCrs(values[values:length - 1][0], values[values:length - 1][1]):mag.
