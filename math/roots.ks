@lazyglobal off.

// currently hard coded max iterations
local max_iter is 100.

// Newtons method for finding roots
function Newton {
  parameter
    f,
    f_prime,
    x_n is 0,
    tolerance is 1e-10.

  // specify initial state
  local x_n1 is x_n * 1000.
  local error is 1e10.
  local iter is 0.

  // wait until error is low or max iterations reached
  until abs(error) < tolerance or iter > max_iter {
    set x_n1 to x_n - (f(x_n) / f_prime(x_n)).
    set error to x_n1 - x_n.

    set x_n to x_n1.
    set iter to iter + 1. 
  }

  return x_n1.
}