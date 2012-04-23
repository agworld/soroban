Soroban::define :AND => lambda { |*args|
  Soroban::getValues(binding, *args).reduce(true) { |s, a| s && a }
}
