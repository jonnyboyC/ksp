@lazyglobal off.
RunOncePath("./utilities/engineResources.ks").
RunOncePath("./utilities/drawVectors.ks").
RunOncePath("./utilities/fp.ks").
RunOncePath("./flightParameters/otherParameters.ks").

function DeorbitControl {
	parameter
		target_periapsis,
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
	local steering_control is ship:retrograde.

	local lock throttle to throttle_control.
	local lock steering to steering_control.

	local engine_list is List().
	list engines in engine_list.

	until vAng(ship:facing:foreVector, ship:retrograde:foreVector) < 1 {
    set steering_control to ship:retrograde.
    update_status_func("Angle " + vAng(ship:facing:foreVector, ship:retrograde:foreVector)).
		update_func().
	}

  set throttle_control to 1.
	until ship:periapsis < target_periapsis {
    
    update_status_func("Angle " + vAng(ship:facing:foreVector, ship:retrograde:foreVector)).

		update_func().
		set engine_list to engine_resources["update_stage"](update_status_func).
    set steering_control to ship:retrograde.
		wait 0.
	}

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

function LandingControl {
	parameter
		face_prograde,
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

  when alt:radar < 500 then {
    gear on.
    update_status_func("Extending Landing Gear").
  }

  when not ChutesSafe THEN {
    update_status_func("Deploying Parachutes").
    ChutesSafe on.
  }
  
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

  WarpTo(eta:periapsis, update_status_func).

  local steering_control is 0.
  if face_prograde {
    set steering_control to ship:srfPrograde.
  } else {
	  set steering_control to ship:srfRetrograde.
  }

	local lock throttle to throttle_control.
	local lock steering to steering_control.

	local engine_list is List().
	list engines in engine_list.

  WarpTo(eta:periapsis, update_status_func).

	local Cds is list().
	local Cd_avg is 0.

	wait until kuniverse:timeWarp:rate = 1.

	local t0 is time.
	until alt:radar < 5 {
		if time - t0 > 5 and Cds:length < 10 {
			local cd is EstimateCd().
			if cd <> 0 {
				Cds:add(EstimateCd()).
				set Cd_avg to reduce(Cds, {parameter sum, element. return sum + element. }).
				set Cd_avg to Cd_avg / Cds:length.
				update_status_func("Cd estimate: " + Cd_avg).	
			}
		}

		update_func().
    if face_prograde {
      set steering_control to ship:srfPrograde.
    } else {
      set steering_control to ship:srfRetrograde.
    }
		wait 0.
	}

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
}