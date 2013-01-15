# Return e raised to the power of the argument
Soroban::define :EXP => lambda { |val|
  Math.exp(val)
}
