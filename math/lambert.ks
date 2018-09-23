@lazyglobal off.
RunOncePath("hyperbolicMath.ks").

function Lambert {
  parameter
    r_vec1,
    r_vec2,
    time_of_flight,
    max_rotations,
    mu

  local r1 is r_vec1:norm.
  local r2 is r_vec2:norm.

  local c is (r_vec2 - r_vec1):mag.
  local s is (c + r1 + r2) / 2.

  local r_vec1_unit is r_vec1:normalized.
  local r_vec2_unit is r_vec2:normalized.

  local h_vec is VCrs(r_vec1_unit, r_vec2_unit).
  local tangent1 is 0.
  local tangent2 is 0.

  local lambda2 is 1 - c / s.
  local lambda is sqrt(lambda2).

  if h < 0 {
    tangent1 to VCrs(r_vec1_unit, h_vec).
    tangent2 to VCrs(r_vec2_unit, h_vec).
  } else {
    tangent1 to VCrs(h_vec, r_vec1_unit).
    tangent2 to VCrs(h_vec, r_vec2_unit).
  }

  set tangent1 to tangent1:normalized.
  set tangent2 to tangent2:normalized.

  if full_rotations < 1 {
    set lambda to -lambda.
    set tangent1 to -1 * tangent1.
    set tangent2 to -1 * tangent2.
  }

  local lambda3 is lambda * lambda2.
  local T = sqrt(2 * mu / s^3) * time_of_flight.

  set max_rotations to min(max_revolutions, HaileyIteration(T, lambda, lambda2, lambda3)).
}

function HaileyIteration {
  parameter
    T,
    lambda,
    lambda2,
    lambda3.

  local max_revolutions = T / constant:pi.
  
  local T00 is arccos(lambda) + lambda * sqrt(1 - lambda2).
  local T0 is T00 + max_revolutions * constant:pi.
  local T1 is 2 / 3 * (1 - lambda3).
  local dt is 0.
  local dTdx is 0.
  local d2Tdx2 is 0.
  local d3Tdx3 is 0

  if max_revolutions > 0 and T < T0 {
    local iter is 0.
    local error is 1.
    local T_min is T0.
    local x_old is 0.
    local x is 0

    until false {
      set dt to TDerivatives(lambda, x_old, T_min).
      set dTdx to dt[0].
      set d2Tdx2 to dt[1].
      set d3Tdx3 to dt[2].

      if dTdx <> 0 {
        set x = x_old - dTdx * d2Tdx2 / (d2Tdx2 ^ 2 - dTdx * d3Tdx3 / 2).
      }

      set error to abs(x_old - x).
      if error < 1e-13 or iter > 12 {
        break;
      }

      set T_min to TimeOfFlight(x, lambda, max_revolutions).
      set x_old to x.
      set iter to iter + 1.
    }
    if (T_min > T) {
      set max_revolutions to max_revolutions - 1. 
    }
  }

  return list(max_revolutions, T00, T0, T1).
}

function TDerivatives {
  parameter
    lambda,
    x,
    T.

  local umx2 is sqrt(1 - x^2).
  local y is sqrt(1 - lambda2^2 * umx2).

  local dTdx is 1 / umx2 * (3 * T * x - 2 + 2 * lambda^3 * x / y).
  local d2Tdx2 is 1 / umx2 * (3 * T + 5 * x * dTdx + 2 * (1 - lambda^2) * lambda^3 / y^3).
  local d3Tdx3 is 1 / umx2 * (7 * T *d2Tdx2 + 8 * dTdx - 6 *(1 - lambda^2) * lambda^5 * x / y^5).

  return list(dTdx, d2Tdx2, d3Tdx3).
}

function TimeOfFlight {
  parameter
    x,
    lambda,
    revolutions.

  local battin is 0.01.
  local lagrange is 0.2.
  local dist is abs(x - 1).

  if dist < lagrange and dist > battin {
    return IzzoTimeOfFlight(x, revolutions).
  }

  if dist < battin {
    return BattinTimeOfFlight(x, lambda).
  } 

  return LancasterTimeOfFlight(x, lambda, revolutions).
}

function IzzoTimeOfFlight {
  parameter
    x,
    revolutions.

  local a is 1 / (1 - x^2).
  if a > 0 {
    local alpha is 2 * arccos(x).
    local beta is 2 * arcsin(sqrt(lambda^2 / a)).

    if lambda < 0 {
      set beta to -beta.
    }

    return (a * sqrt(a) * ((alpha - sin(alpha)) - (beta - sin(beta))) + 2 * revolutions * constant:pi) / 2.
  } else {
    local alpha is arccosh(x).
    local beta is arcsinh(sqrt(lambda^2 / a)).

    if lambda < 0 {
      set beta to -beta.
    }
          
    return (-a * sqrt(-a) * ((beta - sinh(beta)) - (alpha - sinh(alpha)))) / 2.
  }
}

function BattinTimeOfFlight {
  parameter
    x,
    lambda.

  local y is sqrt(1 - lambda^2 * (1 - x^2)).
  local eta is y - lambda * x.
  local s1 is 0.5 * (1 - lambda - x* eta).
  local q is hyperGeometricFunction(3, 1, 2.5, s1).

  return (q * eta^3 + 4 * lambda * eta) / 2. 
}

function LancasterTimeOfFlight {
  parameter
    x,
    lambda,
    revolutions.

  local K is lambda^2.
  local E is x^2 - 1.
  local rho is abs(E).
  local z is sqrt(1 + K * E).
  local y is sqrt(rho).
  local g is x * z - lambda * E.
  local d is 0.

  if E < 0 {
    set d to revolutions * constant:pi + acos(g).
  } else {
    set d to log(g + y * (z - lambda * x)).
  }

  return (x - lambda * z - d / y) / E.
}

function hyperGeometricFunction {
  parameter
    a, 
    b, 
    c
    z,
    tolerance.

  local sum is 1.0.
  local error is 1.0.
  local sum_i is 1.0.
  local i is 0.

  until error < tolerance {
    set sum_i = sum_i * a * b / c * z / i.
    set sum to sum + sum_i.
    set error = abs(sum_i).

    set a to a + 1.
    set b to b + 1.
    set c to c + 1.
    
    set i to i + 1.
  }

  return sum.
}
