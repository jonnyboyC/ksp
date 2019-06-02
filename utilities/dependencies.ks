
local dependencies_set is uniqueSet().
local import_drive is 0.
local additional_segments is list().

// 
function import {
  parameter file_path.

  dependencies_set:add(file_path).
  local drive_path is path(import_drive:tostring() + ":/").

  for segment in additional_segments {
    set drive_path to drive_path:combine(segment).
  }
  runOncePath(drive_path:combine(file_path)).
}

function dependencies {
  return dependencies_set.
}


