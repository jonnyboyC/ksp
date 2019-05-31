local stagesKey is "stages".
local addPartKey is "addPart".
local toJsonKey is "toJson".
local fromJsonKey is "fromJson".

local dryMassKey is "dryMass".
local wetMassKey is "wetMass".
local resourcesKey is "resources".

// generate ship resources
function shipResources {

  // ship resources instance
  local instance is lexicon().

  // create a lexicon of stage properties
  local function createStageProperties {
    return lexicon(
      dryMassKey, 0,
      wetMassKey, 0,
      resourcesKey, lexicon()
    ).
  } 

  // add a part's properties to the stages
  local function addPartToStage {
    parameter
      part is ship:rootPart,
      stageProperties is lexicon().

    set stageProperties[dryMassKey] to stageProperties[dryMassKey] + part:drymass.
    set stageProperties[wetMassKey] to stageProperties[wetMassKey] + part:wetmass.
    local stageResource is stageProperties[resourcesKey].

    // add resources to the stage resources
    for resource in part:resources {
      if not stageResource:hasKey(resource:name) {
        stageResource:add(resource:name, 0).
      }

      set stageResource[resource:name] to stageResource[resource:name] + resource:amount.
    }
  }

  // add a part to ship resources
  local function addPart {
    parameter part is ship:rootpart.

    // select stage based on when it will be decoupled
    local stageProperties is getStage(part:decoupledin).
    addPartToStage(part, stageProperties).
  }

  // get a stage
  local function getStage {
    parameter stageNumber is 0.

    if not instance[stagesKey]:haskey(stageNumber) {
      set instance[stagesKey][stageNumber] to createStageProperties().
    }

    return instance[stagesKey][stageNumber].
  }

  // write to json
  local function toJson {
    parameter jsonPath is "".

    writeJson(instance[stagesKey], jsonPath).
  }

  // read to json
  local function fromJson {
    parameter jsonPath is "".

    set instance[stagesKey] to readJson(jsonPath).
  }

  instance:add(stagesKey, lexicon()).
  instance:add(addPartKey, addPart@).
  instance:add(toJsonKey, toJson@).
  instance:add(fromJsonKey, fromJson@).

  return instance.
}