
// mission keys
global copy_dependencies_key is "copyDependencies".
global run_key is "run".

// available segments
global ascend_segment is "ascend".
global circularize_segment is "circularize".

// internal keys
local dependencies_key is "dependencies".
local drive_key is "drive".
local segments_key is "segments".
local parameters_key is "parameters".

// available mission segments
local mission_segments is lexicon(
  ascend_segment, "/scripts/scriptHelpers/ascend.ks",
  circularize_segment, "/scripts/scriptHelpers/circularize.ks"
).

// change the provide list of argument to an actual run
local function runHelper {
  parameter 
    full_path is "",
    parameters is list().

  print("full_path " + full_path).
  print("parameters " + parameters:join(", ")).

  if parameters:length = 0 {
    runPath(full_path).
    return.
  }
  if parameters:length = 1 {
    runPath(full_path, parameters[0]).
    return.
  }
  if parameters:length = 2 {
    runPath(full_path, parameters[0], parameters[1]).
    return.
  }
  if parameters:length = 3 {
    runPath(full_path, parameters[0], parameters[1], parameters[2]).
    return.
  }
  if parameters:length = 4 {
    runPath(full_path, parameters[0], parameters[1], parameters[2], parameters[3]).
    return.
  }
}

// Mission class
function MissionRunner {
  parameter segments is list().

  local instance is lexicon(
    segments_key, list(),
    parameters_key, list(),
    drive_key, 0,
    dependencies_key, list(),
    copy_dependencies_key, copyDependencies@,
    run_key, run@
  ).

  local function loader { 
    parameter file_path.
    
    instance[dependencies_key]:add(file_path).
    runOncePath("0:/" + file_path).
  }

  // add each segment
  for segment in segments {
    instance[segments_key]:add(segment[0]).
    instance[parameters_key]:add(segment[1]).
  }

  // handle case were zero is falsy
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
    
    print("copying dependencies for segments " + instance[segments_key]:join(", ")).

    // check we actually passed in a scalar
    if not drive:istype("scalar") {
      print("expected scalar drive number").
      print(1/0).
    }

    if drive = 0 {
      print("target drive 0 no need to copy").
      return.
    }

    // set the drive the scripts will be run from probably 1
    set instance[drive_key] to drive.

    // for each mission segment determine dependencies
    for segment in instance[segments_key] {

      // check if we have mission segment in our lex
      if not mission_segments:hasKey(segment) {
        print("Missing segment " + segment:tostring() + " not found.").
        print(1/0).
      }

      // generate a volume 0 file path
      local segment_path is mission_segments[segment].
      local file_path is resolvePath(0, segment_path).

      // run with dependency loading to gather dependencies
      runOncePath(file_path, loader@).
      instance[dependencies_key]:add(segment_path).
    }

    // copy dependencies to drive
    for dependency in instance[dependencies_key] {
      local source_path is resolvePath(0, dependency).
      local destination_path is resolvePath(drive, dependency).

      copyPath(source_path, destination_path).
    }
  }

  // run the mission segments
  local function run {
    print("run segments " + instance[segments_key]:join(", ")).

    // for each mission segment determine dependencies
    for i in range(instance[segments_key]:length) {
      local segment is instance[segments_key][i].
      local parameters is instance[parameters_key][i].

      // check if we have mission segment in our lex
      if not mission_segments:hasKey(segment) {
        print("Missing segment " + segment:tostring() + " not found.").
        print(1/0).
      }

      local segment_path is mission_segments[segment].
      local file_path is resolvePath(instance[drive_key], segment_path).

      runHelper(file_path, parameters).
    }
  }

  return instance.
}
