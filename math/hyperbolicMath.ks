@lazyglobal off.

function ACosH {
  parameter
    x.

  return ln(x + sqrt(x^2 - 1)).
}

function ASinH {
  parameter
    x.

  return ln(x + sqrt(x^2 + 1)).
}

function ATanH {
  parameter
    x.

  return 0.5 * ln((1 + x) / (1 - x)).
}