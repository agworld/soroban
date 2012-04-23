Soroban::define :IF => lambda { |val, if_true, if_false|
  val ? if_true : if_false
}
