# Excel ISBLANK returns true for empty string and null
# It supports one cell as an input
#
Soroban::define :ISBLANK => lambda { |val|
  val.to_s.blank?
}
