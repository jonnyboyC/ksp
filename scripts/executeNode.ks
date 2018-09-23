@lazyglobal off.
RunOncePath("./utilities/engineResources.ks").
RunOncePath("./utilities/utils.ks").

local node to nextnode.
local steering_control is node:deltav.
local throttle_control is 1.0.

local engine_resources is EngineResources(ship).	
local node_vector is node:deltav.
local engine_list is List().

local v_f is (velocityAt(ship, node:eta + time):orbit + node:deltav):mag.
local v_0 is ship:velocity:orbit:mag.

print velocityAt(ship, node:eta + time):orbit.
print node:deltav.
print "velocity final: " + v_f + "velocity initial: " + v_0.

local burn is engine_resources["estimate_burn"](node:deltav, velocityAt(ship, node:eta + time):orbit).
print "burn duration: " + round(burn[0], 3) + " burn start: " + round(burn[1], 3).

local burn_start is burn[1].

local lock steering to steering_control.

local warp_time is (node:eta + time:seconds - (burn_start + 120)).
WarpTo(warp_time).

until vAng(ship:facing:foreVector, node:deltav) < 1 {
  set steering_control to node:deltav.
  wait 0.
}

set warp_time to (node:eta + time:seconds - (burn_start + 5)).
WarpTo(warp_time).

wait until node:eta <= burn_start.
local lock throttle to throttle_control.

until false {
  local max_acc to ship:availableThrust / ship:mass.
  set steering_control to node:deltav.

  if max_acc <> 0 {
    set throttle_control to min(node:deltav:mag / max_acc, 1).
  }

  engine_resources["update_stage"]().

  if vdot(node_vector, node:deltav) < 0 {
    break.
  }

  if node:deltav:mag < 0.1 {
    break.
  }

  wait 0.
}

set throttle_control to 0.

remove node.
unlock throttle.
unlock steering.

set ship:control:pilotMainThrottle to 0.0. 