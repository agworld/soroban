module Soroban

  # Thrown if an invalid formula is assigned to a cell.
  class ParseError < StandardError
  end

  # Thrown if calculation of a cell's formula depends on the value of the same
  # cell.
  class RecursionError < StandardError
  end

  # Thrown if a referenced cell falls outside the limits of a supplied range.
  class RangeError < StandardError
  end

  # Thrown is access is attempted to an undefined cell.
  class UndefinedError < StandardError
  end

end
