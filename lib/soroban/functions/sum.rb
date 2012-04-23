Soroban::define :SUM => lambda { |*args|
  Soroban::getValues(binding, *args).reduce(:+)
}
