// Cast a collection to another
function cast {
  parameter 
    collection,
    cast_type.
  
  if collection:typename = cast_type {
    return collection.
  } 
  if cast_type="List" {
    local lst to list().
    for element in collection {
      lst:add(element).
    } 
    return lst.
  }
  if cast_type="Queue" {
    local que to queue().
    for element in collection {
      que:push(element).
    } 
    return que.
  }
  if cast_type="Stack" {
    local stk is stack().
    local temp is stack().
    set result to stack().
    for element in collection {
      temp:push(element).
    }
    for element in temp {
      stk:push(element).
    }
    return l.
  }
}

// Cast a collection to a list
function to_list { parameter collection. return cast(collection, "List"). }

// Check if all element meet a condition
function all { 
  parameter 
    collection,
    condition. 
    
  for i in collection {
    if not condition(i) return false.
  }

  return true.
}

// Check if any elements meet a condition
function any { 
  parameter 
    collection,
    condition.
    
  for i in collection {
    if condition(i) return true.
  }
  return false.
}

// count the number of elements that meet a condition
function count {
  parameter 
    collection,
    condition.
  
  local result is 0.
    
  for i in collection {
    if condition(i) {
      set result to result + 1.
    }
  }
  return result.
}

// Apply a void function to a collection
function each {
  parameter 
    collection,
    operation.
    
  for i in collection {
    operation(i).
  }
}

// Apply a void function a slice of a collection
function each_slice{
  parameter 
    collection,
    slice_size,
    operation.

  local lst is to_list(collection).
  local i is 0.
  local casted is 0.

  until i > lst:length - 1 {
    set casted to cast(
      lst:sublist(i, min(slice_size, lst:length - 1)),
      collection:typename
    ).
    operation(casted).
    
    set i to i + slice_size.
  }
}

// Apply a void function to each element of a collection with included index
function each_with_index{
  parameter 
    collection,
    operation.
    
  local idx is 0.
  for element in to_list(collection) {
    operation(element, idx).
    set idx to idx + 1.
  }
}

// Find the first element that a condition is meet
function find {
  parameter 
    collection,
    condition. 
    
  for i in collection {
    if condition(i) return i.
  } 
  return false.
}

// Find the index of the first element a condition is meet
function find_index{
  parameter 
    collection,
    condition.
    
  local idx is 0. 

  for element in to_list(collection) {
    if condition(element) return idx. 
    set idx to idx + 1.
  }

  return -1.
}

// Group a collection by some transform return a lexicon
function group_by {
  parameter 
    collection,
    transform.
    
  local result is lex(). 
    
  for element in collection {
    local key is transform(element).
    if result:haskey(key) {
      result[key]:add(element).
    } else {
      set result[key] to list(element).
    }
  }
  for key in result:keys { 
    set result[key] to cast(result[key], collection:typename). 
  } 

  return result.
}

// Apply a transform to a collection
function map {
  parameter 
    collection,
    transform.

  local result is list().
    
  for element in to_list(collection) {
    result:add(transform(element)).
  } 

  return cast(result, collection:typename).
}

// Apply a transform to a collection with index
function map_with_index{
  parameter 
    collection,
    transform.

  local result is list().
  local lst is to_list(collection).
  local i is 0.
  
  until i = lst:length { 
    result:add(transform(lst[i], i + 1)).
    set i to i + 1.
  }

  return cast(result, collection:typename).
}

// Return 
function _max{ 
  parameter
    lst.

  local lst_copy is to_list(lst).
  if lst_copy:length = 0 return false.

  local result is lst_copy[0].
  for i in lst_copy {
    if i > result set result to i.
  }  

  return result.
}

function _min{
  parameter 
    collection.
    
  local lst is to_list(collection).
  if lst:length = 0 return false.

  local result is lst[0].
  for element in lst {
    if element < result set result to element.
  }  

  return result.
}

function partition{
  parameter 
    collection,
    condition.

  local lst is to_lst(collection).
  local result is list(list(), list()).

  for i in lst {
    if condition(i) {
      result[0]:add(i).
    } else {
      result[1]:add(i).
    }
  }
  set result[0] to cast(result[0], collection:typename).
  set result[1] to cast(result[1], collection:typename).

  return result.
}

function reduce {
  parameter 
    collection,
    sum,
    reducer.
    
  for element in collection {
    set sum to reducer(sum, element).
  }  
  return sum.
}

function reject {
  parameter 
    collection,
    condition.
    
  local result is list().
  for element in collection {
    if not condition(element) result:add(i).
  }
  return cast(result, collection:typename).
}

function reverse{ 
  parameter 
    collection.

  local result is stack().
  for i in collection {
    result:push(i).
  } 
  
  return cast(result, collection:typename).
}

function lex_fill {
  parameter
    keys.
    fill.

  local result is lexicon().
  for key in keys {
    results.
  }
}

function filter {
  parameter 
    collection,
    condition.
    
  local result is list().
  for i in to_list(collection) {
    if condition(i) result:add(i). 
  } 
  
  return cast(result, collection:typename).
}

function sort {
  parameter 
    collection,
    condition.
    
  local result is to_list(collection):copy.
  function quickSort { 
    parameter
      A,
      low,
      hi.

    if low < hi {
      local p is pt(A, lo, hi).
      quickSort(A, lo, p).
      quickSort(A, p + 1, hi).
    }
  }

  function pt{
    parameter A,
      low,
      hi.
      
    local pivot is A[lo].
    local i is low - 1.
    local j is hi + 1.

    until false {
      until false { 
        set j to j - 1.
        if condition(A[j], pivot) <= 0 break.
      }
      until false {
        set i to i + 1.
        if condition(A[i], pivot) >= 0 break.
      }
      if i < j {
        local switch is A[i].
        set A[i] to A[j].
        set A[j] to switch.
      } else {
        return j.
      }
    }
  }

  quickSort(result, 0, result:length - 1).
  return cast(result, collection:typename).
}