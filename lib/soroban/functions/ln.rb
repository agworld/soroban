# Return the natural logarithm of the argument
Soroban::define :LN => lambda { |val|
  Math.log(val)
}
