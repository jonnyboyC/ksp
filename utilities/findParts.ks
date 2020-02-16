
@lazyglobal off.

parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). }.

// For Vscode
if false {
  runOncePath("0:/utilities/walkShip.ks").
  runOncePath("0:/utilities/shipProperties.ks").
}

// import dependencies
import("/utilities/walkShip.ks").
import("/utilities/shipProperties.ks").

// write vessel resources to file
local properties is shipProperties(list(heatShieldProperties)). 
walkShip(ship, {
  parameter part is ship:rootpart.

  properties[addPartKey](part).
}).

print(properties).