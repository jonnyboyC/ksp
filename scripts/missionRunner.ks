
local segments_key is "segments".
local copy_dependencies_key is "copyDependencies".
local run_key is "run".
local drive_key is "drive".


local mission_segments is lexicon(
  "ascend", "/scripts/scriptHelper/ascend",
  "circularize", "/scripts/scriptHelper/circularize"
).

//
function mission {
  parameter segments is list().

  local instance is lexicon(
    segments_key, list(),
    drive_key, 0
  ).
  for segment in segments {
    instance:add(segment).
  }

  local function resolvePath {
    parameter
      drive is 0,
      file_path is "".

    if drive = 0 {
      return "0:" + file_path.
    } else {
      return drive:toString() + ":" + file_path.
    }
  }

  // copy dependencies to ship
  local function copyDependencies {
    parameter drive is 0.

    // check we actually passed in a scalar
    if not drive:istype("scalar") {
      print("expected scalar drive number").
      print(1/0).
    }

    // set the drive the scripts will be run from probably 1
    set instance[drive_key] to drive.
    local file_paths is list().

    // for each mission segment determine dependencies
    for segment in instance[segments_key] {
      if not mission_segments:hasKey(segment) {
        print("Missiong segment " + segment:tostring() + " not found.").
        print(1/0).
      }

      local segment_path is mission_segments[segment].
      local file_path is resolvePath(0, segment_path).

      runOncePath(file_path).
      file_paths:add(file_paths).
    }

    // copy dependencies to drive
    for dependency in dependencies() {
      local target_path is resolvePath(0, dependency).
      local destination_path is resolvePath(drive, dependency).
      copyPath(target_path, destination_path).
    }
  }

  //
  local function run {

  }

  instance:add(copy_dependencies_key, copyDependencies@).
  instance:add(run_key, run@).

  return instance.
}
