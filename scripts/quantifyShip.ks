parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). }.

// For Vscode
if false {
  runOncePath("0:/utilities/walkShip.ks").
  runOncePath("0:/utilities/shipResources.ks").
}

// import dependencies
import("utilities/walkShip.ks").
import("utilities/shipResources.ks").

parameter path is "0:/" + ship:name + ".json".

// write vessel resources to file
local resources is shipResources().
walkShip(ship, {
  parameter part is ship:rootpart.

  resources[addPartKey](part).
}).

resources[toJsonKey](path).