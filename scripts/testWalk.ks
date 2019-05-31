runOncePath("0:/utilities/walkShip.ks").
runOncePath("0:/utilities/shipResources.ks").


local resources is shipResources().
walkShip(ship, {
  parameter part is ship:rootpart.

  resources["addPart"](part).
}).

resources["toJson"]("test.json").