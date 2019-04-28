@lazyglobal off.
RunOncePath("0:/utilities/engineResources.ks").
RunOncePath("0:/utilities/drawVectors.ks").
RunOncePath("0:/utilities/fp.ks").
RunOncePath("0:/flightParameters/otherParameters.ks").
RunOncePath("0:/flightParameters/orbitalParameters.ks").


function DeorbitControl {
	parameter
		target_periapsis,
		engine_resources is engineResources(ship),
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	local vector_manager is 0.

	// if debug draw vectors
	if debug {
		set vector_manager to standardVectors().
	}

	local throttle_control is 0.
	local steering_control is ship:retrograde.

	lock throttle to throttle_control.
	lock steering to steering_control.

	until vAng(ship:facing:foreVector, ship:retrograde:foreVector) < 1 {
    set steering_control to ship:retrograde.
    update_status_func("Angle " + vAng(ship:facing:foreVector, ship:retrograde:foreVector)).
		update_func().
	}

  set throttle_control to 1.
	until ship:periapsis < target_periapsis {
    
    update_status_func("Angle " + vAng(ship:facing:foreVector, ship:retrograde:foreVector)).

		update_func().
		engine_resources["update_stage"](update_status_func).
    set steering_control to ship:retrograde.
		wait 0.
	}

	set throttle_control to 0.

	// clear vectors if enabled
	if debug {
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	set ship:control:pilotMainThrottle to 0.0. 
	unlock throttle.
	unlock steering.
}

function LandingControl {
	parameter
		face_prograde,
		update_func is { },
		update_status_func is { parameter message. },
		debug is false.

	// pre pare to deploy parachute if atmosphere exists
	if ship:body:atm:exists {
		when alt:radar < 500 then {
			gear on.
			update_status_func("Extending Landing Gear").
		}

		when not ChutesSafe THEN {
			update_status_func("Deploying Parachutes").
			ChutesSafe on.
		}
	}

	local vector_manager is 0.

	// if debug draw vectors
	if debug {
		set vector_manager to standardvectors().
	}

	// local engine_resources is EngineResources(ship).
	local throttle_control is 0.

  WarpTo(eta:periapsis, update_status_func).

  local steering_control is 0.
  if face_prograde {
    set steering_control to ship:srfPrograde.
  } else {
	  set steering_control to ship:srfRetrograde.
  }

	lock throttle to throttle_control.
	lock steering to steering_control.

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
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	set ship:control:pilotMainThrottle to 0.0. 
	unlock throttle.
	unlock steering.
}