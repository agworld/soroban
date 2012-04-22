Soroban::define :SUM => lambda { |range|
  walk(range).reduce(:+)
}
