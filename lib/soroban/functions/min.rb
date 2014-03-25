# Return the minimum of the supplied values, which may be numbers, labels or ranges.
Soroban::Functions.define :MIN => lambda { |*args|
  Soroban::Helpers.getValues(binding, *args).min
}
