# Average the arguments, which may be numbers, labels or ranges.
Soroban::define :AVERAGE => lambda { |*args|
  values = Soroban::getValues(binding, *args)
  values.reduce(:+) / values.length.to_f
}
