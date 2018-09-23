@lazyglobal off.
RunOncePath("./flightParameters/orbitalParameters").

local r_key is "r_vec".
local v_key is "v_vec".
local mu_key is "mu".
local mech_e_key is "mech_e".
local a_key is "a".
local x_key is "x".
local z_key is "z".
local c_key is "c".
local s_key is "s".
local f_key is "f".
local g_key is "g".
local t_key is "t".
local update_key is "update".

function UniveralParameters {
  parameter
    r_vec,
    v_vec,
    mu.

  local mech_e is MechanicalEnergy(r_vec:mag, v_vec:mag, mu).
  local a is SemiMajorAxis(mu, mech_e).

  local update is {
    parameter 
      x.

    set instance[x_key] to x. 
    local z is UniversalZ(x, instance[a_key]).
    local c is universalC(z).
    local s is universalS(z).

    set instance[z_key] to z.
    set instance[c_key] to c.
    set instance[s_key] to s.
    set instance[f_key] to universalF(x, instance[r_key], c).
    set instance[g_key] to universalG(x, s, instance[t_key], instance[mu_key]).
  }.

  local instance is lexicon().
  instance:add(update_key, update@).
  instance:add(r_key, r_vec).
  instance:add(v_key, v_vec).
  instance:add(mu_key, mu).
  instance:add(mech_e_key, mech_e).
  instance:add(a_key, a).
  instance:add(t_key, time).
  instance:add(x_key, 0).
  instance:add(z_key, 0).
  instance:add(c_key, 0).
  instance:add(s_key, 0).
  instance:add(f_key, 0).
  instance:add(g_key, 0).

  return instance.
}

function UniversalZ {
  parameter
    x,
    a.

  return (x ^ 2) / a.
}

function UniversalC {
  parameter
    z.

  return (1 - cos(sqrt(z))) / z.
}

function UniversalS {
  parameter
    z.

  return (sqrt(z) - sin(sqrt(z))) / sqrt(z ^ 3).
}

function UniversalF {
  parameter
    x,
    r_vec,
    c.

  return 1 - (x ^ 2) / r_vec:mag * c.
}

function UniversalG {
  parameter
    x,
    mu,
    t,
    s.   

  return t - (x ^ 3) / sqrt(mu) * s.
}

function UniversalR {
  parameter
    x,
    z,
    r_vec,
    v_vec,
    mu,
    c,
    s.

  local first is (x ^ 2) * c.
  local second is (VDot(r_vec, v_vec) * x * (1 - z * s)) / sqrt(mu).
  local third is r_vec:mag * (1 - z * c).

  return (first + second + third). 
}

function UniversalT {
  parameter
    x, 
    z,
    r_vec,
    v_vec,
    mu,
    c,
    s.

  local sqrt_mu is sqrt(mu).

  local first is (x ^ 3) * s.
  local second is (VDot(r_vec, v_vec) * (x ^ 2) * c) / sqrt_mu.
  local third is r_vec:mag * x * (1 - z * s).

  return (first + second + third) / sqrt_mu. 
}