@lazyglobal off.

parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). }.

// For Vscode
if false {
  RunOncePath("0:/utilities/fp.ks").
  RunOncePath("0:/flightParameters/orbitalParameters.ks").
}

// import dependencies
import("utilities/fp.ks").
import("flightParameters/orbitalParameters.ks").

function countDown {
  parameter
    duration,
    update_status_func is { parameter message. }.

  from {local til_launch is duration.} until til_launch = 0 step {set til_launch to til_launch - 1.} do {
    update_status_func("Countdown: " + til_launch).
    WAIT 0.2.
  }
}

// automatically stage when an engine flameout occures
function autoStage {
  parameter
    curr_ship,
    engine_list,
    stage_func is {}.

  function stage_engines {
    stage.
    stage_func().
    List engines in engine_list.
    return engine_list.
  }

  if not stage:ready {
    return engine_list.
  }

  if curr_ship:maxthrust = 0 {
    return stage_engines().
  }

  if any(engine_list, { parameter engine. return engine:flameout. }) {
    return stage_engines().
  }

  return engine_list.
}

// deploy parachutes if safe
function autoChute {
  parameter
    update_status_func.

  if not chutesSafe {
    update_status_func("Deploying parachutes").
    chutesSafe on.
  }
}

// default decent periapsis
function defaultDesentPeriapsis {
  parameter
    curr_body.

  if curr_body:atm:exists {
		return curr_body:atm:height * 0.5.
	} else {
	  return curr_body:radius * -0.05.
	}
}

// default laucnh apoapsis
function defaultLaunchApoapsis {
  parameter
    curr_body.

  if curr_body:atm:exists {
		return curr_body:atm:height * 1.1.
	} else {
	  return 30000.
	}
}

// wraps the built in warp with setting
function warpTime {
	parameter
		warp_time,
    update_status_func is {}.    

  local start_time is time.
  local settle_time is 0.

  sas on.
  until kuniverse:timeWarp:isSettled {
    set settle_time to (time - start_time):seconds.
    if settle_time > warp_time {
      sas off.
      return.
    } 
    wait 0.
  }
  wait 2.

  update_status_func("Time Warping for " + round(warp_time - settle_time, 2) + "s").
  kuniverse:timeWarp:warpto(time:seconds + warp_time - settle_time).
  sas off.
}
