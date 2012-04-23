Soroban::define :MAX => lambda { |*args|
  Soroban::getValues(binding, *args).max
}
