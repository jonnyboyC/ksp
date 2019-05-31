

function walkShip {
  parameter
    shipVessel is ship,
    exec is {}.

  local root is shipVessel:rootPart.
  walkShipChild(root, 0, exec).
}

// walk children parts
function walkShipChild {
  parameter
    shipPart is ship:rootpart,
    depth is 0,
    exec is {}.

  exec(shipPart).
  for child in shipPart:children {
    walkShipChild(child, depth + 1, exec).
  }
}




