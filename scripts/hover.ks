@lazyglobal off.
RunOncePath("0:/utilities/engineResources.ks").
RunOncePath("0:/utilities/utils").

local lock steering TO heading(0, 90).

local PID_throttle is PIDLoop(0.1, 2, 2, 0, 1).
local throttle_setting is 0.5.
local Lock throttle to throttle_setting.
local target_height is 10000.

local engine_resources is EngineResources(ship).
stage.

from {local t is 0.} until t > target_height step {set t to t + 1.} do {
  engine_resources["update_stage"].

  SET throttle_setting TO PID_throttle:update(time:seconds, alt:radar).
  set PID_throttle:setPoint to t.
  wait 0.01.
} 

set PID_throttle:setPoint to target_height.

clearscreen.

local Timebase is time:seconds. 
print "Timebase" + Timebase.

Until Timebase + 100 < time:seconds {
  engine_resources["update_stage"].
  set throttle_setting TO PID_throttle:update(time:seconds, alt:radar).

  clearscreen.
  print time:seconds.
  print PID_throttle.
  print PID_throttle:ki.
  print PID_throttle:kd.
  print PID_throttle:error.
  print PID_throttle:changeRate.
  print PID_throttle:errorSum.
  print PID_throttle:input.
  print PID_throttle:output.
  print "P: " + PID_throttle:pTerm.
  print "I: " + PID_throttle:iTerm.
  print "D: " + PID_throttle:dTerm.
  print "Setpoint ThrotSetting: "+ throttle_setting.
  print "Radar" + alt:radar.

  Wait 0.
}
print "Landing".
until ship:status = "LANDED"{
  local Lock throttle to 0.1.
}
local lock throttle to 0.0.
print "Landed".
Wait 0.1.