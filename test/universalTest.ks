@lazyglobal off.
RunOncePath("0:/math/universal.ks").
RunOncePath("0:/math/roots.ks").

local curryUniversalTime is {
  parameter 
    target_time,
    universal.

  local func is {
    parameter x.

    universal["update"](x).
    local t is UniversalT(
      x,
      universal["z"],
      universal["r_vec"],
      universal["v_vec"],
      universal["mu"],
      universal["c"],
      universal["s"]
    ).

    print t.
    return target_time - t.
  }.

  return func.
}.

local curryUniveralTimePrime is {
  parameter
    universal.

  local func is {
    parameter x.

    universal["update"](x).
    return universalR(
      x,
      universal["z"],
      universal["r_vec"],
      universal["v_vec"],
      universal["mu"],
      universal["c"],
      universal["s"]
    ) / universal["mu"].
  }.

  return func.
}.

local universal is UniveralParameters(SoiPositionShip(), ship:velocity:orbit, ship:body:mu).

local f is curryUniversalTime(60, universal).
local f_prime is curryUniveralTimePrime(universal).

local guess is sqrt(ship:body:mu) * (60) / SemiMajorAxisShip().

Newton(f, f_prime, guess).