@lazyglobal off.
// John Chabot Domination of the universe

parameter 
	face_prograde is false,
	target_periapsis is -1000.

local debug is true.

// initialize libraries
RunOncePath("./utilities/utils.ks").
RunOncePath("./flightParameters/orbitalParameters.ks").
RunOncePath("./scripts/scriptHelpers/decentControls.ks").
clearscreen.

// gear off when over 300


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
set target_periapsis to target_periapsis * 1000.
if target_periapsis = -1000000 {
  set target_periapsis to DefaultDesentPeriapsis(ship:body).
}

// Print status
PrintStatusWindow("decend.ks", version).

// Console Count Down
UpdateStatusWindowMessage("Target periapsis is: " + target_periapsis + "m").

local engine_list is DeorbitControl(
	target_periapsis,
	update_status,
	update_status_message,
	debug
).

LandingControl(
	false,
	update_status,
	update_status_message,
	debug
).

ClearStatusWindowOther().
wait 1.
set ship:control:pilotMainThrottle to 0.0. 
