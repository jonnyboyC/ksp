@lazyglobal off.
// John Chabot Domination of the universe

parameter 
	launch_direction is 90,
	target_apoapsis is 0.

local debug is true.

// initialize libraries
RunOncePath("./utilities/utils.ks").
RunOncePath("./flightParameters/orbitalParameters.ks").
RunOncePath("./scripts/scriptHelpers/launchControls.ks").
clearscreen.

// Status update function
local update_status is {
	UpdateStatusWindow().
}.

local update_status_message is {
	parameter
		message.

	UpdateStatusWindowMessage(message).
}.

// set launch defaults
set target_apoapsis to target_apoapsis * 1000.
if target_apoapsis = 0 {
  set target_apoapsis to DefaultLaunchApoapsis(ship:body).
}
local target_orbital_speed is CircularOrbitVelocity(target_apoapsis + ship:body:radius, ship:body:mu).

// Print status
PrintStatusWindow("launch.ks", version).

// Console Count Down
CountDown(10, update_status_message).
UpdateStatusWindowMessage("Target apoapsis is: " + target_apoapsis + "m").

local mass_rate is AscentControl(
	target_apoapsis,
	launch_direction,
	update_status,
	update_status_message,
	debug
).
ClearStatusWindowOther().

local circular_node is CruiseToCircularizationControl(
	mass_rate,
	update_status,
	update_status_message,
	debug
).

local engine_list to CircularizationControl (
	mass_rate,
	circular_node,
	update_status,
	update_status_message,
	debug
).

wait 1.
remove circular_node.

set ship:control:pilotMainThrottle to 0.0. 
