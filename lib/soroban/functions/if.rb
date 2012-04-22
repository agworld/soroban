Soroban::define :IF => lambda { |val, if_true, _if_false|
  val ? if_true : if_false
}
