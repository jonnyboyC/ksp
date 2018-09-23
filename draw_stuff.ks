@lazyglobal off.

run once orbitalParameters.

local h_vec is AngularMomentumShip().
local n_vec is NodeVectorShip().
local e_vec is EccentricityVectorShip().

local h_vec_draw is VecDraw(
  V(0, 0, 0),
  h_vec:normalized * 10,
  RED,     
  "", 
  1.0,
  TRUE,
  0.2
).
set h_vec_draw:vecUpdater to { return AngularMomentumShip():normalized * 10. }.

local n_vec_draw is VecDraw(
  V(0, 0, 0),
  n_vec:normalized * 10,
  Green,
  "",
  1.0,
  TRUE,
  0.2
).
set n_vec_draw:vecUpdater to {return NodeVectorShip():normalized * 10.}.


local e_vec_draw is VecDraw(
  V(0, 0, 0),
  e_vec:normalized * 10,
  Blue,
  "",
  1.0,
  TRUE,
  0.2
).
set e_vec_draw:vecUpdater to {return EccentricityVectorShip():normalized * 10.}.

// Control scheme
until 0 {

	// UpdateStatusWindow(ship).
	wait 0.
}