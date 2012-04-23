# Logical or of supplied arguments, which may be booleans, labels or ranges.
Soroban::define :OR => lambda { |*args|
  Soroban::getValues(binding, *args).reduce(false) { |s, a| s || a }
}
