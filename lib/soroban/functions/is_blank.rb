# Excel ISBLANK returns true for empty string and null
# It doesn't return true for strings with length > 0
#   ie ISBLANK( " " ) => false
#      ISBLANK( "" ) => true
#      ISBLANK( NULL ) => true
#      ISBLANK( 0 ) => false
#
# It supports one cell as an input
#
Soroban::Functions.define :ISBLANK => lambda { |val|
  val.to_s.length.zero?
}
