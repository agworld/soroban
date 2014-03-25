# Logical or of supplied arguments, which may be booleans, labels or ranges.
# Note that the reduce call will short-circuit as long as the |l, r| arguments
# are used in the correct order.
Soroban::Functions.define :OR => lambda { |*args|
  Soroban::Helpers.getValues(binding, *args).reduce(false) { |l, r| l || r }
}
