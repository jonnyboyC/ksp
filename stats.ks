// This function return an estimate of drag
// vel : vector -> velocity relative to the surface
// mass: double -> mass of the craft
// rho_0: double -> sea level density of the craft
// alt: double -> current altitude
function drag {
  parameter vel
  parameter mass
  parameter rho_0
  parameter alt

  local cd is 0.2
  local area is mass * 0.08
  local rho is 0.5 * constant:e ^ (alt / -5000)
  

  return 0.5 * rho * vel:mag * cd * area
}
