function walkShip {
  parameter shipVessel is ship.

  local root is shipVessel:rootPart.
  walkShipChild(root).
}

local space is "  ".

local function walkShipChild {
  parameter shipPart, depth is 0.

  local spaceDepth is "".
  for i in range(depth) {
    set spaceDepth to spaceDepth + space.
  }

  print(spaceDepth + "name: " + shipPart:name).
  print(spaceDepth + "title: " + shipPart:title).

  if shipPart:hasParent {
    print(spaceDepth + "parent: " + shipPart:parent).
  }

  // wait 0.1.

  for child in shipPart:children {
    walkShipChild(child, depth + 1).
  }
}