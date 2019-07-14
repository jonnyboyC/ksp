parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). }.

// For Vscode
if false {
  RunOncePath("0:/flightParameters/orbitalParameters.ks").
}

// import dependencies
import("flightParameters/orbitalParameters.ks").

// print the status window
function printStatusWindow {
  parameter
    script_name,
    kos_version.

  clearscreen.

  print "+---------------------------------------------------------+".
  print "|                                           kOS v.        |".
  print "+---------------------------------------------------------+".
  print "| Orbit parameters:                                       |".
  print "+---------------------------------------------------------+".
  print "| Ap :                      Pe :                          |".
  print "| Inc:                      Ecc:                          |".
  print "| Phi:                      Nu :                          |".
  print "| Vel:                      Srf:                          |".
  print "| x:              y:             z:                       |".
  print "+---------------------------------------------------------+".
  print "| Status:                                                 |".
  print "+---------------------------------------------------------+".
  print "|                                                         |".
  print "|                                                         |".
  print "|                                                         |".  
  print "|                                                         |".
  print "+---------------------------------------------------------+".

  print script_name at (2, 1).
  print kos_version at (51, 1).
}

// update the status window message
function updateStatusWindowMessage {
  parameter
    message.

  print message:padright(47) at (10, 11).
}

// update the first line of the status window
function updateStatusWindowOther1 {
  parameter
    message.

  print message:padright(55) at (2, 13).
}

// update the second line of the status window
function UpdateStatusWindowOther2 {
  parameter
    message.

  print message:padright(55) at (2, 14).
}

// updat the thrid lien of the status window
function updateStatusWindowOther3 {
  parameter
    message.

  print message:padright(55) at (2, 15).
}

// clear status window
function clearStatusWindowOther {
  updateStatusWindowOther1("").
  UpdateStatusWindowOther2("").
  updateStatusWindowOther3("").
}

// update the status window with statistics
function updateStatusWindow {
  local apoapsis_str is round(ship:apoapsis / 1000, 1) + " km".
  local periapsis_str is round(ship:periapsis / 1000, 1) + " km".
  local inclination_str is round(ship:orbit:inclination, 2) + " deg".
  local eccentricty_str is round(ship:orbit:eccentricity, 2):toString().
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
