# Return the maximum of the supplied values, which may be numbers, labels or ranges.
Soroban::define :MAX => lambda { |*args|
  Soroban::getValues(binding, *args).max
}
