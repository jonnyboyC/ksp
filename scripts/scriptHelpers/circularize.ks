@lazyglobal off.

parameter 
  import is { parameter path is "". RunOncePath("0:" + path).}.

// Declare dependecies
if false {
	RunOncePath("0:/utilities/engineResources.ks").
	RunOncePath("0:/utilities/drawVectors.ks").
	RunOncePath("0:/flightParameters/orbitalParameters.ks").
}

// import dependencies
import("/utilities/engineResources.ks").
import("/utilities/drawVectors.ks").
import("/flightParameters/orbitalParameters.ks").

// circularize the current craft to it's current apoapsis
function CircularizationControl {
  parameter
		mass_rate is 0,
		engine_resources is EngineResources(ship),
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

  CircularizationCoastControl(mass_rate, engine_resources, update_func, update_status_func, debug).
  CircularizationBurnControl(mass_rate, engine_resources, update_func, update_status_func, debug).
}

// Control scheme for cruising to circularization burn
local function CircularizationCoastControl {
	parameter
		mass_rate is 0,
		engine_resources is EngineResources(ship),
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	local vector_manager is 0.

	// if debug draw vectors
	if debug {
		set vector_manager to standardvectors().
	}

	local throttle_control is 0.
	local steering_control is ship:prograde.

	lock throttle to throttle_control.
	lock steering to steering_control.

	local v_f_vec is CircularOrbitVelocityShip().
	local v_0_vec is VelocityAtApoapsisShip().

	// estimate burn dv
	local burn_dv is v_f_vec - v_0_vec.
	local burn is engine_resources["estimate_burn"](v_f_vec, v_0_vec, mass_rate).
	local burn_time is burn["time"].
	local burn_start is burn["start"].

	// warp near to apoapsis if no atmosphere exists
	if not ship:body:atm:exists {
		local warp_time is (eta:apoapsis - (burn_start + 60)).
		WarpTo(warp_time, update_status_func).
	}

	until (eta:apoapsis <= (burn_start + 60)) {
		update_func().
		wait 0.
	}

	set v_f_vec to CircularOrbitVelocityShip().
	set v_0_vec to VelocityAtApoapsisShip().

	set burn_dv to v_f_vec - v_0_vec.
	set steering_control to -burn_dv.

	set burn to engine_resources["estimate_burn"](v_f_vec, v_0_vec, mass_rate).
  set burn_time to burn["time"].
	set burn_start to burn["start"].

	update_status_func("Aligning to circularization burn").
	until vAng(ship:facing:foreVector, -burn_dv) < 1 {
		set steering_control to -burn_dv.
		update_func().
		wait 0.
	}

	update_status_func("Coasting to burn").
	until eta:apoapsis <= burn_start {
		update_func().
	}

	if debug {
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	set ship:control:pilotMainThrottle to 0.0. 
	unlock throttle.
	unlock steering.
}

// Control scheme for burn to circularize
local function CircularizationBurnControl {
	parameter
		mass_rate is 0,
		engine_resources is EngineResources(ship),
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	local vector_manager is 0.

	// if debug draw vectors
	if debug {
		set vector_manager to standardvectors().
	}

	local v_f_vec is CircularOrbitVelocityShip().
	local v_0_vec is VelocityAtApoapsisShip().

	// estimate burn dv
	local burn_dv is v_f_vec - v_0_vec.
	local burn is engine_resources["estimate_burn"](v_f_vec, v_0_vec, mass_rate).
	local burn_time is burn["time"].

	local throttle_control is 1.0.
	local steering_control is -burn_dv.

	lock throttle to throttle_control.
	lock steering to steering_control.

	update_status_func("Burning for " + round(burn_time, 3) + "s").
	local apoapsis_0 is alt:apoapsis.

	until false {
		update_func().
		set steering_control to -burn_dv.

		if alt:periapsis > 0 {
			set throttle_control to min(
				0.1 + ((apoapsis_0 - alt:periapsis) / apoapsis_0),
				1
			).
		}

		if debug {
			vector_manager["show"]().
		}

		// stage as neccessary
		engine_resources["update_stage"](update_status_func).

		// when periapsis is more than 99% of the og apoapsis break
		if alt:periapsis > apoapsis_0 * 0.99 {
			break.
		}

		wait 0.
	}

	update_status_func("Circularization Complete").

	set throttle_control to 0.
	set ship:control:pilotMainThrottle to 0.0. 
	wait 0.

	if debug {
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	unlock throttle.
	unlock steering.
}