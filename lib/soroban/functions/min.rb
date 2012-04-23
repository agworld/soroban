# Return the minimum of the supplied values, which may be numbers, labels or ranges.
Soroban::define :MIN => lambda { |*args|
  Soroban::getValues(binding, *args).min
}
