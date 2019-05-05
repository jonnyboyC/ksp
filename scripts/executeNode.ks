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

local v_0_vec is velocityAt(ship, active_node:eta + time):orbit.
local v_f_vec is v_0_vec + active_node:deltav.

// calculate burn time
local burn is engine_resources["estimate_burn"](v_f_vec, v_0_vec).
print("burn duration: " + round(burn["time"], 3) + " burn start: " + round(burn["start"], 3)).

local burn_start is burn["start"].
lock steering to steering_control.

// warp to near the node
local warp_time is (active_node:eta + time:seconds - (burn_start + 120)).
WarpTo(warp_time).

// make sure ship is aligned with node
until vAng(ship:facing:foreVector, active_node:deltav) < 1 {
  set steering_control to active_node:deltav.
  wait 0.
}

// warp very close to start of node
set warp_time to (active_node:eta + time:seconds - (burn_start + 5)).
WarpTo(warp_time).

// lock throttle
wait until active_node:eta <= burn_start.
lock throttle to throttle_control.

// control for node
until false {
  local max_acc to ship:availableThrust / ship:mass.
  set steering_control to active_node:deltav.

  if max_acc <> 0 {
    set throttle_control to min(active_node:deltav:mag / max_acc, 1).
  }

  // stage if needed
  engine_resources["update_stage"]().

  if vdot(node_vector, active_node:deltav) < 0 {
    break.
  }

  if active_node:deltav:mag < 0.1 {
    break.
  }

  // wait a physics tick
  wait 0.
}

// reset controls
set throttle_control to 0.

remove active_node.
unlock throttle.
unlock steering.

set ship:control:pilotMainThrottle to 0.0. 