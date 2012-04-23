# Logical and of supplied arguments, which may be booleans, labels or ranges.
Soroban::define :AND => lambda { |*args|
  Soroban::getValues(binding, *args).reduce(true) { |s, a| s && a }
}
