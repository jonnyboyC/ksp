parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). }.

clearScreen.

// For Vscode
if false {
	RunOncePath("0:/scripts/missionRunner.ks").
}

// import dependencies
import("scripts/missionRunner.ks").

local runner is MissionRunner(list(
  list(ascend_segment, list()),
  list(circularize_segment, list())
)).

runner[copy_dependencies_key](1).
runner[run_key]().