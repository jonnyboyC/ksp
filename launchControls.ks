@lazyglobal off.
set config:stat to true.

run once engineResources.
run once drawVectors.
run once otherParameters.

// Pitch control scheme pitch harder as we approach orbital velocity
local function PitchControl {
	parameter
		ship,
		ship_speed,
		target_orbital_speed.

	local twr is ship:maxthrust / ship:mass.
	local pitch to 90 * (1 - (ship_speed / (target_orbital_speed * 0.6))).

	return pitch.
}

// Ascent control scheme for ascent portion of launch
local function AscentControl {
	parameter
		target_apoapsis,
		launch_direction,
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	// gear off when over 300
	when alt:radar > 300 then {
		gear off.
	}

	local h_vec_draw is 0.
	local n_vec_draw is 0.
	local e_vec_draw is 0.

	// if debug draw 
	if debug {
		set h_vec_draw to DisplayVectorShip({ return AngularMomentumShip():normalized * 10. }, Red).
		set n_vec_draw to DisplayVectorShip({ return NodeVectorShip():normalized * 10. }, Blue).
		set e_vec_draw to DisplayVectorShip({ return EccentricityVectorShip():normalized * 10. }, Green).
	}

	local target_orbital_speed is CircularOrbitVelocity(target_apoapsis + ship:body:radius, ship:body:mu).
	local speed is 0.
	local time_step is 0.1.
	local pitch is 90.

	local engine_resources is EngineResources(ship).
	local throttle_control to 1.0.
	local steering_control is heading(launch_direction, pitch).

	local lock throttle to throttle_control.
	local lock steering to steering_control.

	local engine_list is 0.
	list engines in engine_list.

	// Control scheme
	until ship:apoapsis > target_apoapsis {
		if ship:apoapsis / target_apoapsis < 0.9 {
			wait time_step.
		}

		update_func().
		set speed to ship:velocity:surface:mag.
		set engine_list to engine_resources["update_stage"](update_status_func).

		if speed < target_orbital_speed / 20 {
			set steering_control to heading(launch_direction, pitch).
		} else {
			set pitch to PitchControl(ship, speed, target_orbital_speed).
			set steering_control to heading(launch_direction, pitch).

			if pitch < 5 {
				set pitch to 5.
			}

			set steering_control to heading(launch_direction, pitch).
		}
		wait 0.
	}

	local mass_rate is engine_resources["mass_rate"]().

	set throttle_control to 0.
	wait 0.

	if debug {
		set h_vec_draw:vecUpdater to DoNothing.
		set n_vec_draw:vecUpdater to DoNothing.
		set e_vec_draw:vecUpdater to DoNothing.

		set h_vec_draw to 0.
		set n_vec_draw to 0.
		set e_vec_draw to 0.
	}

	unlock throttle.
	unlock steering.
	return mass_rate.
}

local function CruiseToCircularizationControl {
	parameter
		mass_rate,
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	local h_vec_draw is 0.
	local n_vec_draw is 0.
	local e_vec_draw is 0.

	if debug {
		set h_vec_draw to DisplayVectorShip({ return AngularMomentumShip():normalized * 10. }, Red).
		set n_vec_draw to DisplayVectorShip({ return NodeVectorShip():normalized * 10. }, Blue).
		set e_vec_draw to DisplayVectorShip({ return EccentricityVectorShip():normalized * 10. }, Green).
	}

	local engine_resources is EngineResources(ship).
	local throttle_control is 0.
	local steering_control is ship:prograde.

	local lock throttle to throttle_control.
	local lock steering to steering_control.

	local v_f is CircularOrbitVelocityShip().
	local v_0 is VelocityAtApoapsisShip().

	local burn_dv is v_f - v_0.
	local burn is engine_resources["estimate_burn"](v_f, v_0, mass_rate).
	local burn_time is burn[0].
	local burn_start is burn[1].

	if not ship:body:atm:exists {
		local warp_time is (eta:apoapsis - (burn_start + 60)).
		WarpTo(update_status_func, warp_time).
	}

	until (eta:apoapsis <= (burn_start + 60)) {
		update_func().
		wait 0.
	}

	set v_f to CircularOrbitVelocityShip().
	set v_0 to VelocityAtApoapsisShip().

	set burn_dv to v_f - v_0.
	add node(time:seconds + eta:apoapsis, 0, 0, burn_dv).
	local circular_node to nextnode.
	set steering_control to circular_node:deltav.

	set burn to engine_resources["estimate_burn"](v_f, v_0, mass_rate).
  set burn_time to burn[0].
	set burn_start to burn[1].

	update_status_func("Aligning to maneuver node").
	until vAng(ship:facing:foreVector, circular_node:deltav) < 1 {
		set steering_control to circular_node:deltav.
		update_func().
		wait 0.
	}

	update_status_func("Coasting to maneuver node").
	until circular_node:eta <= burn_start {
		update_func().
	}

	unlock throttle.
	unlock steering.

	return circular_node.
}

local function CircularizationControl {
	parameter
		mass_rate,
		circular_node,
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	local h_vec_draw is 0.
	local n_vec_draw is 0.
	local e_vec_draw is 0.

	if debug {
		set h_vec_draw to DisplayVectorShip({ return AngularMomentumShip():normalized * 10. }, Red).
		set n_vec_draw to DisplayVectorShip({ return NodeVectorShip():normalized * 10. }, Blue).
		set e_vec_draw to DisplayVectorShip({ return EccentricityVectorShip():normalized * 10. }, Green).
	}

	local throttle_control is 1.0.
	local steering_control is circular_node:deltav.

	local lock throttle to throttle_control.
	local lock steering to steering_control.

	local engine_resources is EngineResources(ship).	
	local node_vector is circular_node:deltav.
	local engine_list is List().
	list engines in engine_list.

	local v_f is CircularOrbitVelocityShip().
	local v_0 is VelocityAtApoapsisShip().
	local burn is engine_resources["estimate_burn"](v_f, v_0, mass_rate).
	local burn_time is burn[1].

	update_status_func("Burning for " + round(burn_time, 3) + "s").

	until false {
		update_func().
		local max_acc to ship:maxthrust / ship:mass.
		set steering_control to circular_node:deltav.

		if max_acc <> 0 {
			set throttle_control to min(circular_node:deltav:mag / max_acc, 1).
		}

		set engine_list to engine_resources["update_stage"](update_status_func).

		if vdot(node_vector, circular_node:deltav) < 0 {
			break.
		}

		if circular_node:deltav:mag < 0.1 {
			break.
		}

		wait 0.
	}

	update_status_func("Circularization Complete").

	set throttle_control to 0.

	if debug {
		set h_vec_draw:vecupdater to DoNothing.
		set n_vec_draw:vecupdater to DoNothing.
		set e_vec_draw:vecupdater to DoNothing.

		set h_vec_draw to 0.
		set n_vec_draw to 0.
		set e_vec_draw to 0.
	}

	unlock heading.
	unlock steering.
	return engine_list.
}