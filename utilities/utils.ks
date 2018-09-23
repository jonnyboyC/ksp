@lazyglobal off.
RunOncePath("./utilities/fp.ks").

function CountDown {
  parameter
    time,
    update_status_func is { parameter message. }.

  from {local til_launch is time.} until til_launch = 0 step {set til_launch to til_launch - 1.} do {
    update_status_func("Countdown: " + til_launch).
    WAIT 0.2.
  }
}

function AutoStage {
  parameter
    ship,
    engine_list,
    stage_func.

  function stage_engines {
    stage.
    stage_func().
    List engines in engine_list.
    return engine_list.
  }

  if not stage:ready {
    return engine_list.
  }

  if ship:maxthrust = 0 {
    return stage_engines().
  }

  if any(engine_list, { parameter engine. return engine:flameout. }) {
    return stage_engines().
  }

  return engine_list.
}

function AutoChute {
  parameter
    update_status_func.

  if not chutesSafe {
    update_status_func("Deploying parachutes").
    chutesSafe on.
  }
}

function DefaultDesentPeriapsis {
  parameter
    body.

  if body:atm:exists {
		return body:atm:height * 0.5.
	} else {
	  return body:radius * -0.05.
	}
}


function DefaultLaunchApoapsis {
  parameter
    body.

  if body:atm:exists {
		return body:atm:height * 1.1.
	} else {
	  return 30000.
	}
}


function WarpTo {
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

function PrintStatusWindow {
  parameter
    script_name,
    kos_version.

  clearscreen.

  print "+--------------------------------------------------------+".
  print "|                                           kOS v.       |".
  print "+--------------------------------------------------------+".
  print "| Orbit parameters:                                      |".
  print "+--------------------------------------------------------+".
  print "| Ap :                      Pe :                         |".
  print "| Inc:                      Ecc:                         |".
  print "| Phi:                      Nu :                         |".
  print "| Vel:                      Srf:                         |".
  print "| x:              y:             z:                      |".
  print "+--------------------------------------------------------+".
  print "| Status:                                                |".
  print "+--------------------------------------------------------+".
  print "|                                                        |".
  print "|                                                        |".
  print "|                                                        |".  
  print "|                                                        |".
  print "+--------------------------------------------------------+".

  print script_name at (2, 1).
  print kos_version at (51, 1).
}

function UpdateStatusWindowMessage {
  parameter
    message.

  print message:padright(47) at (10, 11).
}

function UpdateStatusWindowOther1 {
  parameter
    message.

  print message:padright(55) at (2, 13).
}

function UpdateStatusWindowOther2 {
  parameter
    message.

  print message:padright(55) at (2, 14).
}

function UpdateStatusWindowOther3 {
  parameter
    message.

  print message:padright(55) at (2, 15).
}

function ClearStatusWindowOther {
  UpdateStatusWindowOther1("").
  UpdateStatusWindowOther2("").
  UpdateStatusWindowOther3("").
}

function UpdateStatusWindow {
  local apoapsis_str is round(ship:apoapsis / 1000, 1) + " km".
  local periapsis_str is round(ship:periapsis / 1000, 1) + " km".
  local inclination_str is round(ship:orbit:inclination, 2) + " deg".
  local eccentricty_str is ToString(round(ship:orbit:eccentricity, 2)).
  local flight_path_angle_str is round(FlightPathAngleShip(), 2) + " deg".
  local true_anomaly_str is round(TrueAnomalyShip(), 2) + " deg". 

  local velocity_str is round(ship:velocity:orbit:mag, 1) + " km/s".
  local surface_velocity_str is round(ship:velocity:surface:mag, 1) + " km/s".
  local velocity_x_str is round(ship:velocity:orbit:x, 1) + " km/s".
  local velocity_y_str is round(ship:velocity:orbit:y, 1) + " km/s".
  local velocity_z_str is round(ship:velocity:orbit:z, 1) + " km/s".

  print apoapsis_str:padright(12) at (7,5).
  print periapsis_str:padright(12) at (33, 5).
  print inclination_str:padright(12) at (7,6).
  print eccentricty_str:padright(12) at (33, 6).
  print flight_path_angle_str:padright(12) at (7, 7).
  print true_anomaly_str:padright(12) at (33, 7).
  print velocity_str:padright(12) at (7, 8).
  print surface_velocity_str:padright(12) at (33, 8).
  print velocity_x_str:padright(10) at (5, 9).
  print velocity_y_str:padright(10) at (21, 9).
  print velocity_z_str:padright(10) at (36, 9).
}

function ToString {
  parameter
    obj.

  return obj + "".
}
