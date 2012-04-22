Soroban::define :VLOOKUP => lambda { |value, range, col, inexact|
  fc, fr, tc, tr = Soroban::getRange(range)
  i = walk("#{fc}#{fr}:#{fc}#{tr}").find_index(value)
  return nil if i.nil?
  (0...i).each { fr.next! }
  (1...col).each { fc.next! }
  eval("@#{fc}#{fr}.get")
}
