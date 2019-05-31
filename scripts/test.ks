function main {
  function func {
    return "function".
  }

  parameter func is "parameter".
  local func is "variable".
  local func is { return "delegate". }.
  lock func to "lock".

  print(func).
}

main().