# Average the arguments, which may be numbers, labels or ranges.
Soroban::Functions.define :AVERAGE => lambda { |*args|
  values = Soroban::Helpers.getValues(binding, *args)
  values.reduce(:+) / values.length.to_f
}
