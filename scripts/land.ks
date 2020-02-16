parameter 
  import is { parameter file_path. runOncePath("0:/" + file_path). },
  arguments is list().

clearScreen.

// For Vscode
if false {
	RunOncePath("0:/scripts/missionRunner.ks").
  RunOncePath("0:/utilities/utils.ks").
}

// set default arguments if necessary
if not arguments:istype("list") or arguments:length <> 2 {
  set arguments to list(DefaultLaunchApoapsis(ship:body), 90).
}

// import dependencies
import("scripts/missionRunner.ks").
import("utilities/utils.ks").

local runner is MissionRunner(list(
  list(selectLandingSegment, list(DefaultLaunchApoapsis(ship:body), 90)),
  list(deorbitSegment, list()),
  list(landSegment, list())
)).

// runner[copy_dependencies_key](1).
runner[run_key]().