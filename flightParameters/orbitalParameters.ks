@lazyglobal off.

function InclinationShip {
  local h_vec is AngularMomentumShip().
  return Inclination(h_vec).
}

function Inclination {
  parameter
    h_vec.

  return ArcCos(h_vec:y / h_vec:mag).
}

function TrueAnomalyShip {
  local h_vec is AngularMomentumShip().
  local n_vec is NodeVector(h_vec).

  return TrueAnomaly(n_vec, SoiPositionShip()).
}

function TrueAnomaly {
  parameter
    n_vec,
    r_vec.

  return ArcCos(VDot(n_vec, r_vec) / (n_vec:mag * r_vec:mag)).
}

function ArgumentOfPeriapsisShip {
  local n_vec is NodeVectorShip().
  local e_vec is EccentricityVector(ship:body:mu, SoiPositionShip(), ship:velocity:orbit).

  return ArgumentOfPeriapsis(n_vec, e_vec).
}

function ArgumentOfPeriapsis {
  parameter
    n_vec,
    e_vec.

  return VAng(n_vec, e_vec).
}

// Mechanical Energy of the ships current orbit
function MechanicalEnergyShip {
  return MechanicalEnergy(SoiPositionShip():mag, ship:velocity:orbit:mag, ship:body:mu).
}

// Mechanical Energy of a given orbit
function MechanicalEnergy {
  parameter
    r,
    v,
    mu.

  local vel_comp is (v ^ 2) / 2.
  local grav_comp is mu / r.

  return vel_comp - grav_comp.
}

// Flight path angle of ships current location
function FlightPathAngleShip {
  return FlightPathAngle(SoiPositionShip(), ship:velocity:orbit).
}

// Fligth path of at a given location and velocity
function FlightPathAngle {
  parameter
    r_vec, 
    v_vec.

  return VAng(r_vec, v_vec) - 90.
}

// Angular momentum of the ships current orbit
function AngularMomentumShip {
  return AngularMomentum(SoiPositionShip(), ship:velocity:orbit).
}

// Angular momentum of a given position and velocity
function AngularMomentum {
  parameter
    r_vec,
    v_vec.

  return VCrs(r_vec, v_vec).
}

function NodeVectorShip {
  local h_vec is AngularMomentumShip().
  return NodeVector(h_vec).
}

function NodeVector {
  parameter
    h_vec.

  return VCrs(V(0, 1, 0), h_vec).
}

function EccentricityVectorShip {
  return EccentricityVector(ship:body:mu, SoiPositionShip(), ship:velocity:orbit).
}

function EccentricityVector {
  parameter
    mu,
    r_vec,
    v_vec.

  local first is (v_vec:mag ^ 2 - mu / r_vec:mag) * r_vec.
  local second is VDot(r_vec, v_vec) * v_vec.

   return (1 / mu) * (first - second).
}

function SemiMajorAxisShip {
  local mech_e is MechanicalEnergyShip().
  return SemiMajorAxis(ship:body:mu, mech_e).
}

function SemiMajorAxis {
  parameter
    mu,
    mech_e.

  return -mu / (2 * mech_e).
}

// Semi Latus Rectum of the ships current orbit
function SemiLatusRectumShip {
  return SemiLatusRectum(SoiPositionShip(), ship:velocity:orbit, ship:body:mu).
}

// Semi Latus Rectum of a given position velocity and a bodies gravitational parameter
function SemiLatusRectum {
  parameter
    r_vec,
    v_vec,
    mu.

  local h is AngularMomentum(r_vec, v_vec):mag.
  return (h ^ 2) / mu.
}

// Velocity of a circular orbit at the ships apoapsis
function CircularOrbitVelocityShip {
  local target_radius is ship:obt:apoapsis + ship:body:radius.
  return CircularOrbitVelocity(target_radius, ship:body:mu).
}

// Velocity of a circular orbit of a given body at a given altitude
function CircularOrbitVelocity {
  parameter
    target_radius,
    mu.

  local r_vec is PositionAtApoapsisShip().
  local h_vec is AngularMomentumShip().

  return sqrt(mu / target_radius) * VCrs(r_vec, h_vec):normalized.
}

function PositionAtPeriapsisShip {
  local r_periapsis is ship:obt:periapsis + ship:body:radius.
  local e_vec is EccentricityVectorShip().
  local r_vec is e_vec:normalized * r_periapsis.

  return r_vec.
}

function PositionAtApoapsisShip {
  local r_apoapsis is ship:obt:apoapsis + ship:body:radius.
  local e_vec is EccentricityVectorShip().
  local r_vec is -e_vec:normalized * r_apoapsis.

  return r_vec.
}

// Velocity of the current ship at apoapsis s
function VelocityAtApoapsisShip {
  local r_vec is PositionAtApoapsisShip().
  return VelocityAtRadius(r_vec, AngularMomentumShip()).
}

function SoiPositionShip {
  return ship:position - ship:body:position.
}

function VelocityAtRadius {
  parameter
    r_vec,
    h_vec.

  return h_vec:mag / r_vec:mag * VCrs(r_vec, h_vec):normalized.
}

function EccentricityShip {
  return Eccentricity(SoiPositionShip(), ship:velocity:orbit, ship:body:mu).
}

function Eccentricity {
  parameter
    r_vec,
    v_vec,
    mu.

  local mech_e is MechanicalEnergy(r_vec:mag, v_vec:mag, mu).
  local h is AngularMomentum(r_vec, v_vec).

  return sqrt(1 + (2 * mech_e * h:mag ^ 2) / (mu ^ 2)).

}