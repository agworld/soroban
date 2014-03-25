# Return a value from the supplied range by searching the first column for the
# supplied value, and then reading the result from the matching row.
Soroban::Functions.define :VLOOKUP => lambda { |value, range, col, inexact|
  fc, fr, tc, tr = Soroban::Helpers.getRange(range)
  i = walk("#{fc}#{fr}:#{fc}#{tr}").find_index(value)
  if i.nil?
    nil
  else
    (0...i).each { fr.next! }
    (1...col).each { fc.next! }
    eval("@#{fc}#{fr}.get")
  end
}
