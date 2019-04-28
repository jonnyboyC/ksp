@lazyglobal off.
RunOncePath("0:/utilities/engineResources.ks").
RunOncePath("0:/utilities/utils.ks").

// get current node off node stack
local active_node to nextnode.
local steering_control is active_node:deltav.
local throttle_control is 1.0.

// get engine resources
local engine_resources is EngineResources(ship).	
local node_vector is active_node:deltav.

// get velocity current velocity and target velcoity
local v_f is (velocityAt(ship, active_node:eta + time):orbit + active_node:deltav):mag.
local v_0 is ship:velocity:orbit:mag.

// report required needed
print(velocityAt(ship, active_node:eta + time):orbit).
print(active_node:deltav).
print("velocity final: " + v_f + "velocity initial: " + v_0).

// calculate burn time
local burn is engine_resources["estimate_burn"](node:deltav, velocityAt(ship, node:eta + time):orbit).
print("burn duration: " + round(burn["time"], 3) + " burn start: " + round(burn["start"], 3)).

local burn_start is burn[1].
lock steering to steering_control.

// warp to near the node
local warp_time is (node:eta + time:seconds - (burn_start + 120)).
WarpTo(warp_time).

// make sure ship is aligned with node
until vAng(ship:facing:foreVector, node:deltav) < 1 {
  set steering_control to node:deltav.
  wait 0.
}

// warp very close to start of node
set warp_time to (node:eta + time:seconds - (burn_start + 5)).
WarpTo(warp_time).

// lock throttle
wait until node:eta <= burn_start.
lock throttle to throttle_control.

// control for node
until false {
  local max_acc to ship:availableThrust / ship:mass.
  set steering_control to node:deltav.

  if max_acc <> 0 {
    set throttle_control to min(node:deltav:mag / max_acc, 1).
  }

  // stage if needed
  engine_resources["update_stage"]().

  if vdot(node_vector, node:deltav) < 0 {
    break.
  }

  if node:deltav:mag < 0.1 {
    break.
  }

  wait 0.
}

// reset controls
set throttle_control to 0.

remove node.
unlock throttle.
unlock steering.

set ship:control:pilotMainThrottle to 0.0. 