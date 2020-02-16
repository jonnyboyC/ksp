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

function DeorbitControl {
	parameter
		target_periapsis,
		engine_resources is engineResources(ship),
		update_func is { },
		update_status_func is { parameter message. }.

	local vector_manager is 0.

	// if debug draw vectors
	if defined debug {
		set vector_manager to standardvectors().
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
	if defined debug {
		vector_manager["clear"]().
		set vector_manager to 0.
	}

	set ship:control:pilotMainThrottle to 0.0. 
	unlock throttle.
	unlock steering.
}

function LandingControl {
}

if parameters:length > 0 {
	DeorbitControl(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]).
}