@lazyglobal off.

parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). },
	parameters is list().

// For Vscode
if false {
	RunOncePath("0:/utilities/engineResources.ks").
	RunOncePath("0:/utilities/drawVectors.ks").
	RunOncePath("0:/flightParameters/orbitalParameters.ks").
}

// import dependencies
import("utilities/engineResources.ks").
import("utilities/drawVectors.ks").
import("flightParameters/orbitalParameters.ks").


// Pitch control scheme pitch harder as we approach orbital velocity
function pitchControl {
	parameter
		curr_ship is ship,
		ship_speed is 0,
		target_orbital_speed is 0.

	local twr is curr_ship:maxthrust / curr_ship:mass.
	local pitch to 90 * (1 - (ship_speed / (target_orbital_speed * 0.6))).

	return pitch.
}

// Ascent control scheme for ascent portion of launch
function ascentControl {
	parameter
		target_apoapsis is 0,
		launch_direction is 90,
		engine_resources is EngineResources(ship),
		update_func is { },
		update_status_func is { parameter message. }.

	// gear off when over 300
	when alt:radar > 300 then {
		gear off.
	}

	local vector_manager is 0.

	// if debug draw vectors
	if defined debug {
		set vector_manager to standardvectors().
	}

	// determine velocity for circular opbit at a given apoapsis
	local target_orbital_speed is circularOrbitVelocity(
		target_apoapsis + ship:body:radius,
		ship:body:mu,
		positionAtApoapsisShip(),
		angularMomentumShip()
	).

	local pitch is 90.
	local speed is 0.
	local time_step is 0.1.

	// lock ship controls
	local throttle_control to 1.0.
	local steering_control is heading(launch_direction, pitch).

	lock throttle to throttle_control.
	lock steering to steering_control.

	// Control scheme
	until ship:apoapsis > target_apoapsis {

		// introduce control delay during majority of accent
		if ship:apoapsis / target_apoapsis < 0.9 {
			wait time_step.
		}

		// update status
		update_func().
		if defined debug {
			vector_manager["show"]().
		}

		set speed to ship:velocity:surface:mag.
		engine_resources["update_stage"](update_status_func).

		// if we're less than 1 / 20th total required velocity fly straight
		if speed < target_orbital_speed:mag / 20 {
			set steering_control to heading(launch_direction, pitch).

		// else use pitch control
		} else {
			set pitch to pitchControl(ship, speed, target_orbital_speed:mag).

			// minimum pitch
			if pitch < 5 {
				set pitch to 5.
			}

			set steering_control to heading(launch_direction, pitch).
		}
		wait 0.
	}

	// set throttle to 0 and wait a tick to ensure it's applied
	set throttle_control to 0.
	wait 0.

	// clear vectors if enabled
	if defined debug {
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	// unlock controls
	unlock throttle.
	unlock steering.
}

if parameters:length > 0 {
	ascentControl(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]).
}