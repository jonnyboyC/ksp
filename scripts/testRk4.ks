@lazyglobal off.
RunOncePath("./math/rungeKutta.ks").
RunOncePath("./flightParameters/otherParameters.ks").

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
  local density is 1.
  local Cd is 1.
  dx:add(x[1]).

  local gravity_acc is -(ship:body:mu * x[0]:normalized) / (x[0]:mag) ^ 2.
  local pressure is CalcPressure(ship:body, x[0]).
  local density is CalcDensity(pressure, Molecular_Mass[ship:body:name], ship:sensors:temp).
  local drag_acc is -density * Cd * (x[1]:mag)^2 * x[1]:normalized / (2 * ship:mass).
  local thrust_acc is -ship:maxThrust * x[1]:normalized / ship:mass .

  //dx:add(gravity_acc).
  dx:add(gravity_acc + drag_acc).
  print "pressure: " + pressure + " density: " + density.
  //dx:add(gravity_acc + drag_acc + thrust_acc).
  return dx.
}.

local x0 is list().
x0:add(V(700_000, 0, 0)).
x0:add(V(0, 1900, 0)).

local values is RungeKutta(x0, 1, 600, decend).

print VCrs(x0[0], x0[1]):mag.
print VCrs(values[values:length - 1][0], values[values:length - 1][1]):mag.
