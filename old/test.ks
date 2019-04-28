@lazyglobal off.

run once stats.
run once constants.

clearscreen.

local Lock throttle to 1.0.
local Lock steering to heading(90, 90).
wait 1.
stage.

local velocity is ship:velocity:surface.
local mass is ship:mass.
local pressure is calcPressure(kerbin, ship:altitude).
local temperature is ship:sensors:temp.
local density is CalcDensity(pressure, molecularMass["kerbin"], temperature).
local drag is CalcDragForce(velocity, mass, density).
local accerlation is 0.

list engines IN temp.
local engine is temp[0].
local expectedDrag is 0.


until ship:altitude > 100000 {
  Set velocity to ship:velocity:surface.
  Set mass to ship:mass.
  Set pressure to calcPressure(kerbin, ship:altitude).
  Set temperature to ship:sensors:temp.

  Set density to CalcDensity(pressure, molecularMass["kerbin"], temperature).
  Set drag to CalcDragForce(velocity, mass, density).
  Set accerlation to ship:sensors:acc:mag - localG(ship).
  Set expectedDrag to ship:availableThrust.

  print "Expected Drag: " + round(expectedDrag, 2) + " KN" at(0, 0).
  print "Calc Drag: " + round(drag, 2) + " KN" at(0, 1).


  // print "Speed: " + round(velocity:mag, 2) + " m/s" at(0, 0).
  // print "mass: " + round(mass, 2) + " metric tons" at(0, 1).
  // print "pressure: " + round(pressure * constant:AtmToKPa, 2) + " Pa" at(0, 2).
  // print "temperature: " + round(temperature, 2) + " K" at (0, 3).
  // print "density: " + round(density, 4) + " kg/m^3" at (0, 4).
  // print "drag: " + round(drag) + " kN" at (0, 5).
}
