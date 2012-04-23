# Sum the arguments, which may be numbers, labels or ranges.
Soroban::define :SUM => lambda { |*args|
  Soroban::getValues(binding, *args).reduce(:+)
}
