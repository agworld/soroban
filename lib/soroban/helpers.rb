require 'soroban/parser'

module Soroban

  # Return true if the supplied data represents a formula.
  def self.formula?(data)
    data.to_s.slice(0..0) == '='
  end

  # Return true if the supplied data is a number.
  def self.number?(data)
    Float(data.to_s) && true rescue false
  end

  # Return true if the supplied data is a boolean.
  def self.boolean?(data)
    /^(true|false)$/i.match(data.to_s) && true || false
  end

  # Return true if the supplied data is a string.
  def self.string?(data)
    /^["](\"|[^"])*["]$/.match(data.to_s) && true || /^['][^']*[']$/.match(data.to_s) && true || false
  end

  # Return true if the supplied data is a range.
  def self.range?(data)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(data.to_s) && true || false
  end

  # Return true if the supplied data is of no recognised format.
  def self.unknown?(data)
    !self.formula?(data) && !self.number?(data) && !self.boolean?(data) && !self.string?(data)
  end

  # Return the components of a range.
  def self.getRange(range)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(range.to_s).to_a[1..-1]
  end

  # Return an array of values for the supplied arguments (which may be numbers, labels and ranges).
  def self.getValues(binding, *args)
    args.map { |arg| Soroban::range?(arg) ? ValueWalker.new(arg, binding).map : arg }.flatten
  end

end
