@lazyglobal off.

function arccosh {
  parameter
    x.

  return ln(x + sqrt(x^2 - 1)).
}

function arcsinh {
  parameter
    x.

  return ln(x + sqrt(x^2 + 1)).
}

function arctanh {
  parameter
    x.

  return 0.5 * ln((1 + x) / (1 - x)).
}