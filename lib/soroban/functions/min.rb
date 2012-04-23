Soroban::define :MIN => lambda { |*args|
  Soroban::getValues(binding, *args).min
}
