@lazyglobal off.

// Is the current transfer orbit valid
function ValidTransferOrbit {
  parameter
    p,
    e,
    start_radius,
    finish_radius.

  if start_radius >= p / (1 + e) and finish_radius <= p / (1 - e) {
    return true.
  } 

  return false.
}

function TransferOribitMechE {
  parameter
    e,
    p,
    mu.

  return -mu * (1 - e^2) / (2 * p). 
}

function TransferOribitAngMomentum {
  parameter
    mu,
    p.

  return sqrt(mu * p).
}

function HohmannTransferMechE {
  parameter
    start_radius,
    finish_radius,
    mu.
  
  return -mu / (start_radius - finish_radius).
}

function OrbitalVelocity {
  parameter
    start_radius,
    mech_e,
    mu.

  return sqrt(2*((mu / start_radius) + mech_e)).
}