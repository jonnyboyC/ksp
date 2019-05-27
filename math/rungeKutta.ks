@lazyglobal off.

function RungeKutta {
  parameter
    x0,
    dt,
    end_t,
    diff_eq.

  local x is list().
  local steps is ceiling(end_t / dt) - 1.

  x:add(x0).
  print x[0].
  from {local step is 1.} until step > steps step {set step to step + 1.} do {
    x:add(RungeKuttaStep(x[step - 1], step * dt, dt, diff_eq)).
    // print x[step].
  }

  return x.
}

function RungeKuttaStep {
  parameter
    x0,
    t,
    h,
    diff_eq.

  local dx0 is diff_eq(x0, t).

  local x1 is list().
  local i is 0.
  until i = x0:length { 
    x1:add(x0[i] + 0.5 * dx0[i] * h).
    set i to i + 1.
  }

  local dx1 is diff_eq(x1, t + h * 0.5).

  local x2 is list().
  set i to 0.
  until i = x1:length { 
    x2:add(x0[i] + 0.5 * dx1[i] * h).
    set i to i + 1.
  }

  local dx2 is diff_eq(x2, t + h * 0.5).

  local x3 is list().
  set i to 0.
  until i = x2:length {
    x3:add(x0[i] + dx2[i] * h).
    set i to i + 1.
  }

  local dx3 is diff_eq(x3, t + h).

  local xf is list().
  set i to 0.
  until i = x3:length {
    xf:add(x0[i] + h / 6 * (dx0[i] + 2 * (dx1[i] + dx2[i] + dx3[i]))).
    set i to i + 1.
  }

  return xf.
}