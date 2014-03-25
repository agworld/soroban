# Sum the arguments, which may be numbers, labels or ranges.
Soroban::Functions.define :SUM => lambda { |*args|
  Soroban::Helpers.getValues(binding, *args).reduce(:+)
}
