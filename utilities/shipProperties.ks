global stagesKey is "stages".
global addPartKey is "addPart".
global toJsonKey is "toJson".
global fromJsonKey is "fromJson".

local dryMassKey is "dryMass".
local wetMassKey is "wetMass".
local resourcesKey is "resources".
local enginesKey is "engines".
local heatShieldsKey is "heatShields".

local initializeKey is "initialize".
local conditionKey is "condition".
local modifyKey is "modify".

function exit {
  parameter message is "".

  print(message).
  print(1 / 0).
}

// define a resource to be gathered
function shipProperty {
  parameter 
    initialize is lexicon(),
    condition is { parameter part. return false. },
    modify is { parameter stageResource, part. return. }.

  if not initialize:istype("Lexicon") {
    exit("resource must be lexicon " + initialize:typename).
  }

  if not condition:istype("UserDelegate") {
    exit("condition must be delegate provided " + condition:typename).
  }

  if not modify:istype("UserDelegate") {
    exit("modify must be UserDelegate provided " + modify:typename).
  }

  // creat a resource instance
  return lexicon(
    initializeKey, initialize,
    conditionKey, condition,
    modifyKey, modify
  ).
}

// resource for fuel
global fuelProperties is shipProperty(
  lexicon(
    resourcesKey, lexicon()
  ),
  { 
    parameter part is ship:rootpart.
    return true.
  },
  { 
    parameter 
      stageProperties is lexicon(),
      part is ship:rootpart.

    local stageResource is stageProperties[resourcesKey].

    // add resources to the stage resources
    for resource in part:resources {
      print(resource).

      if not stageResource:hasKey(resource:name) {
        stageResource:add(resource:name, 0).
      }

      print(resource:name + " amount " + resource:amount).
      set stageResource[resource:name] to stageResource[resource:name] + resource:amount.
    }
  }
).

// resource for fuel
global engineProperties is shipProperty(
  lexicon(
    enginesKey, list()
  ),
  { 
    parameter part is ship:rootpart.
    return part:istype("engine").
  },
  { 
    parameter 
      stageProperties,
      part.

    stageProperties[enginesKey]:add(part:name).
  }
).

global massProperties is shipProperty(
  lexicon(
    dryMassKey, 0,
    wetMassKey, 0
  ),
  {
    parameter part is ship:rootpart.
    return true.
  },
  { 
    parameter 
      stageProperties,
      part.

    set stageProperties[dryMassKey] to stageProperties[dryMassKey] + part:drymass.
    set stageProperties[wetMassKey] to stageProperties[wetMassKey] + part:wetmass.
  }
).

global heatShieldProperties is shipProperty(
  lexicon(
    heatShieldsKey, list()
  ),
  {
    parameter part is ship:rootpart.

    for resource in part:resources {
      if resource:name = "Ablator" {
        return true.
      }
    }
    return false.
  },
  { 
    parameter 
      stageProperties,
      part.

    stageProperties[heatShieldsKey]:add(part).
  }
).

// generate ship resources
function shipProperties {
  parameter
    properties is list(
      fuelProperties,
      engineProperties,
      massProperties
    ).

  // ship resources instance
  local instance is lexicon().

  // create a lexicon of stage properties
  local function createStageProperties {
    local stageProperties is lexicon().

    for property in properties {
      local initialize is property[initializeKey].

      for key in initialize:keys {
        local hasCopy is initialize[key]:hassuffix("copy").

        local copy is choose initialize[key]:copy()
          if hasCopy
          else initialize[key].

        set stageProperties[key] to copy.
      }
    }

    return stageProperties.
  } 

  // add a part's properties to the stages
  local function addPartToStage {
    parameter
      part is ship:rootPart,
      stageProperties is lexicon().

    for property in properties {
      if property[conditionKey](part) {
        property[modifyKey](stageProperties, part).
      }
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

    print(jsonPath).
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