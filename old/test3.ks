@lazyglobal off.

set config:stat to true.
run once newton.

local quad is { 
  parameter 
    x. 
    
  local val is 1.5 * x^2 - 5.
  print val.
  return val. 
}.
local quad_prime is { 
  parameter 
    x. 
    
  local val is 3 * x.
  print val.
  return val.
}.

local root is Newton(quad, quad_prime, 1).
print root.