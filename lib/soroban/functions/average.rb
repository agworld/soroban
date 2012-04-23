Soroban::define :AVERAGE => lambda { |*args|
  values = Soroban::getValues(binding, *args)
  values.reduce(:+) / values.length.to_f
}
