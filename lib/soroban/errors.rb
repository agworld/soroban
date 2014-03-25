module Soroban

  # Raised if an invalid formula is assigned to a cell.
  class ParseError < StandardError
  end

  # Raised if calculation of a cell's formula depends on the value of the same
  # cell.
  class RecursionError < StandardError
  end

  # Raised if a referenced cell falls outside the limits of a supplied range.
  class RangeError < StandardError
  end

  # Raised if access is attempted to an undefined cell.
  class UndefinedError < StandardError
  end

end
