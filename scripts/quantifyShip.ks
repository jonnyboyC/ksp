runOncePath("0:/utilities/walkShip.ks").
runOncePath("0:/utilities/shipResources.ks").

parameter path is "ship.json".

// write vessel resources to file
local resources is shipResources().
walkShip(ship, {
  parameter part is ship:rootpart.

  resources["addPart"](part).
}).

resources["toJson"](path).