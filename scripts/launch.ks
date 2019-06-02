@lazyglobal off.
// John Chabot Domination of the universe

parameter 
	launch_direction is 90,
	target_apoapsis is 0.

global debug is true.

// initialize libraries
RunOncePath("0:/utilities/utils.ks").
RunOncePath("0:/flightParameters/orbitalParameters.ks").
runOncePath("0:/scripts/scriptHelpers/ascend.ks").
runOncePath("0:/scripts/scriptHelpers/circularize.ks").
RunOncePath("0:/utilities/engineResources.ks").
clearscreen.

// Status update function
local update_status is UpdateStatusWindow@.
local update_status_message is UpdateStatusWindowMessage@.

// set launch defaults
set target_apoapsis to target_apoapsis * 1000.
if target_apoapsis = 0 {
  set target_apoapsis to DefaultLaunchApoapsis(ship:body).
}

// Print status
PrintStatusWindow("launch.ks", version).

// Console Count Down
CountDown(10, update_status_message).
UpdateStatusWindowMessage("Target apoapsis is: " + target_apoapsis + "m").

local engine_resources is EngineResources(ship).

local mass_rate is AscentControl(
	target_apoapsis,
	launch_direction,
	engine_resources,
	update_status,
	update_status_message
).
ClearStatusWindowOther().

CircularizationControl(
	mass_rate,
	engine_resources,
	update_status,
	update_status_message
).

wait 1.

set ship:control:pilotMainThrottle to 0.0. 

wait 0.
