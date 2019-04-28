function StandardVectors {
  local draw_vectors is DrawVectors().
  draw_vectors["add_vector"]({ return AngularMomentumShip():normalized * 10.}, Red).
  draw_vectors["add_vector"]({ return NodeVectorShip():normalized * 10.}, Green).
  draw_vectors["add_vector"]({ return EccentricityVectorShip():normalized * 10.}, Blue).

  return draw_vectors.
}

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

function DrawVectors {
  local vectors_ is List().

  local add_vector is {
    parameter
      func,
      color.

    local vec is VecDraw(
      V(0, 0, 0),
      func(),
      color,     
      "", 
      1.0,
      TRUE,
      0.2
    ).
    set vec:vecUpdater to func@.
    vectors_:add(vec).
  }.

  local remove is {
    parameter
      index.

    vectors_:remove(index).
    updates_:remove(index).
    colors_:remove(index).
  }.

  local update is {
    for vec in vectors_ {
    }
  }.

  local show is {
    for vec in vectors_ {
      set vec:show to true.
    }
  }.

  local hide is {
    for vec in vectors_ {
      set vec:show to false.
    }
  }.

  local instance is lexicon().

  instance:add("add_vector", add_vector@).
  instance:add("remove", remove@).
  instance:add("update", update@).
  instance:add("show", show@).
  instance:add("hide", hide@).

  return instance.
}