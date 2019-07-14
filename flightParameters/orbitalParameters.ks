@lazyglobal off.

// get inclination of ship
function inclinationShip {
  local h_vec is angularMomentumShip().
  return inclination(h_vec).
}

// get inclination based on angular momentum vector
function inclination {
  parameter
    h_vec.

  return ArcCos(h_vec:y / h_vec:mag).
}

// get true anomaly of ship
function trueAnomalyShip {
  local h_vec is angularMomentumShip().
  local n_vec is nodeVector(h_vec).

  return trueAnomaly(n_vec, SoiPositionShip()).
}

// get tree anomaly based on angular mometum vector and
// node vector
function trueAnomaly {
  parameter
    n_vec,
    r_vec.

  return arcCos(VDot(n_vec, r_vec) / (n_vec:mag * r_vec:mag)).
}

// get argument of periapsis of ship
function argumentOfPeriapsisShip {
  local n_vec is nodeVectorShip().
  local e_vec is eccentricityVector(ship:body:mu, soiPositionShip(), ship:velocity:orbit).

  return argumentOfPeriapsis(n_vec, e_vec).
}

// get argument of periapsis of ship from node vector
// and eccentricity vector
function argumentOfPeriapsis {
  parameter
    n_vec,
    e_vec.

  return vAng(n_vec, e_vec).
}

// Mechanical Energy of the ships current orbit
function mechanicalEnergyShip {
  return mechanicalEnergy(SoiPositionShip():mag, ship:velocity:orbit:mag, ship:body:mu).
}

// Mechanical Energy of a given orbit
function mechanicalEnergy {
  parameter
    radius,
    vel,
    mu.

  local vel_comp is (vel ^ 2) / 2.
  local grav_comp is mu / radius.

  return vel_comp - grav_comp.
}

// Flight path angle of ships current location
function flightPathAngleShip {
  return flightPathAngle(soiPositionShip(), ship:velocity:orbit).
}

// Fligth path of at a given location and velocity
function flightPathAngle {
  parameter
    r_vec, 
    v_vec.

  return vAng(r_vec, v_vec) - 90.
}

// Angular momentum of the ships current orbit
function angularMomentumShip {
  return angularMomentum(soiPositionShip(), ship:velocity:orbit).
}

// Angular momentum of a given position and velocity
function angularMomentum {
  parameter
    r_vec,
    v_vec.

  return VCrs(r_vec, v_vec).
}

// node vector of the current ship
function nodeVectorShip {
  local h_vec is AngularMomentumShip().
  return NodeVector(h_vec).
}

// node vector based on angular momentum
function nodeVector {
  parameter
    h_vec.

  return vCrs(v(0, 1, 0), h_vec).
}

// eccentricity vector of the current ship
function eccentricityVectorShip {
  return eccentricityVector(ship:body:mu, soiPositionShip(), ship:velocity:orbit).
}

// eccentricty vector by on mu and the current position and velocity vectors
function eccentricityVector {
  parameter
    mu,
    r_vec,
    v_vec.

  local first is (v_vec:mag ^ 2 - mu / r_vec:mag) * r_vec.
  local second is VDot(r_vec, v_vec) * v_vec.

  return (1 / mu) * (first - second).
}

// semi major axis of the ship
function semiMajorAxisShip {
  local mech_e is mechanicalEnergyShip().
  return semiMajorAxis(ship:body:mu, mech_e).
}

// semi major axis based on mu and mechanical energy
function semiMajorAxis {
  parameter
    mu,
    mech_e.

  return -mu / (2 * mech_e).
}

// Semi Latus Rectum of the ships current orbit
function semiLatusRectumShip {
  return semiLatusRectum(soiPositionShip(), ship:velocity:orbit, ship:body:mu).
}

// Semi Latus Rectum of a given position velocity and a bodies gravitational parameter
function semiLatusRectum {
  parameter
    r_vec,
    v_vec,
    mu.

  local h is angularMomentum(r_vec, v_vec):mag.
  return (h ^ 2) / mu.
}

// velocity of a circular orbit at the ships apoapsis
function circularOrbitVelocityShip {
  local target_radius is ship:obt:apoapsis + ship:body:radius.
  local r_vec is positionAtApoapsisShip().
  local h_vec is angularMomentumShip().

  return circularOrbitVelocity(target_radius, ship:body:mu, r_vec, h_vec).
}

// velocity of a circular orbit of a given body at a given altitude
function circularOrbitVelocity {
  parameter
    target_radius,
    mu,
    r_vec,
    h_vec.

  return sqrt(mu / target_radius) * VCrs(r_vec, h_vec):normalized.
}

// position of the ship at periapsis
function positionAtPeriapsisShip {
  local r_periapsis is ship:obt:periapsis + ship:body:radius.
  local e_vec is eccentricityVectorShip().
  local r_vec is e_vec:normalized * r_periapsis.

  return r_vec.
}

// position of the ship at apoapsis
function positionAtApoapsisShip {
  local r_apoapsis is ship:obt:apoapsis + ship:body:radius.
  local e_vec is eccentricityVectorShip().
  local r_vec is -e_vec:normalized * r_apoapsis.

  return r_vec.
}

// Velocity of the current ship at apoapsis s
function velocityAtApoapsisShip {
  local r_vec is PositionAtApoapsisShip().
  return VelocityAtRadius(r_vec, AngularMomentumShip()).
}

function soiPositionShip {
  return ship:position - ship:body:position.
}

// velocity at a given radius
function velocityAtRadius {
  parameter
    r_vec,
    h_vec.

  return h_vec:mag / r_vec:mag * VCrs(r_vec, h_vec):normalized.
}

// eccentricity of the ship
function eccentricityShip {
  return eccentricity(SoiPositionShip(), ship:velocity:orbit, ship:body:mu).
}

// eccentricity based on mu and the current position and velocity vectors
function eccentricity {
  parameter
    r_vec,
    v_vec,
    mu.

  local mech_e is mechanicalEnergy(r_vec:mag, v_vec:mag, mu).
  local h is angularMomentum(r_vec, v_vec).

  return sqrt(1 + (2 * mech_e * h:mag ^ 2) / (mu ^ 2)).

}