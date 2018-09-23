@lazyglobal off.

function test {

  local name is "".

  local greet_Name is {
    return "hello " + name.
  }.

  local set_name is {
    parameter 
      new_name.

    set name to new_name.
  }.

  local instance is lexicon().

  instance:add("name", name).
  instance:add("set", set_name@).
  instance:add("greet", greet_Name@).

  return instance.
}


local test_instance is test().
test_instance["set"]("John").
print test_instance["greet"]().
print test_instance["name"].
