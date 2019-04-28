@lazyglobal off.

RunOncePath("0:/flightParameters/orbitalParameters.ks").

// display a vector relative to the current ship
function DisplayVectorShip {
  parameter
    update_func,
    color.

  local vec is VecDraw(
    V(0, 0, 0),
    update_func(),
    color,     
    "", 
    1.0,
    true,
    0.2
  ).
  set vec:vecUpdater to update_func.
  return vec.
}

// generate the standard vectors for angular momentum, node and eccentricity
function StandardVectors {
  local draw_vectors is DrawVectors().
  draw_vectors["add_vector"]("h", { return AngularMomentumShip():normalized * 10.}, Red).
  draw_vectors["add_vector"]("n", { return NodeVectorShip():normalized * 10.}, Green).
  draw_vectors["add_vector"]("e", { return EccentricityVectorShip():normalized * 10.}, Blue).

  return draw_vectors.
}

// helper functionaility to draw and show debug vectors around the current ship
function DrawVectors {

  // vectors being managed
  local vec_map_ is lex().

  // add a vector to the collection
  local function add_vector {
    parameter
      key,    // name to associate with vector
      func,   // function to draw the end point of the vector
      color.  // color of the vector

    // initial vector draw
    local vec is VecDraw(
      V(0, 0, 0),
      func(),
      color,     
      key, 
      1.0,
      true,
      0.2
    ).

    // set vector updater to func delegate
    set vec:vecUpdater to func@.

    // add to collection
    vec_map_:add(key, vec).
  }.

  // remove a vector from the manager
  local function remove {
    parameter
      key.

    local vec is vec_map_[key].
    set vec:vecUpdater to donothing. 
    vec_map_:remove(key).
  }.

  // show all vectors
  local function show {
    for vec in vec_map_:values {
      set vec:show to true.
    }
  }.

  // hid all vectors
  local function hide {
    for vec in vec_map_:values {
      set vec:show to false.
    }
  }.

  // clear all vectors
  local function clear {
    for vec in vec_map_:values {
      set vec:vecUpdater to donothing. 
    }

    vec_map_:clear().
  }

  local instance is lexicon().

  instance:add("add_vector", add_vector@).
  instance:add("remove", remove@).
  instance:add("show", show@).
  instance:add("hide", hide@).
  instance:add("clear", clear@).

  return instance.
}