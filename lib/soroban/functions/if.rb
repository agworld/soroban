# Return one of two values depending on the value of the supplied boolean.
Soroban::Functions.define :IF => lambda { |val, if_true, if_false|
  val ? if_true : if_false
}
