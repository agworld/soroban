require 'soroban/parser'

module Soroban

  def self.formula?(data)
    data.to_s.slice(0..0) == '='
  end

  def self.number?(data)
    Float(data.to_s) && true rescue false
  end

  def self.boolean?(data)
    /^(true|false)$/i.match(data.to_s) && true || false
  end

  def self.string?(data)
    /^["](\"|[^"])*["]$/.match(data.to_s) && true || /^['][^']*[']$/.match(data.to_s) && true || false
  end

  def self.range?(data)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(data.to_s) && true || false
  end

  def self.unknown?(data)
    !self.formula?(data) && !self.number?(data) && !self.boolean?(data) && !self.string?(data)
  end

  def self.getRange(range)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(range.to_s).to_a[1..-1]
  end

  def self.getValues(binding, *args)
    args.map { |arg| Soroban::range?(arg) ? Walker.new(arg, binding).map : arg }.flatten
  end

end
