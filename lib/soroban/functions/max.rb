# Return the maximum of the supplied values, which may be numbers, labels or ranges.
Soroban::Functions.define :MAX => lambda { |*args|
  Soroban::Helpers.getValues(binding, *args).max
}
