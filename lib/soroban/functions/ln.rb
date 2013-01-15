# Return the minimum of the supplied values, which may be numbers, labels or ranges.
Soroban::define :LN => lambda { |val|
  Math.log(val)
}
