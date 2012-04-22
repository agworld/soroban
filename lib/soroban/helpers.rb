require 'soroban/parser'

module Soroban

  def self.parser
    @@parser ||= SorobanParser.new
  end

  def self.formula?(data)
    data.to_s.slice(0..0) == '='
  end

  def self.number?(data)
    Float(data.to_s) && true rescue false
  end

  def self.boolean?(data)
    /^true$/i.match(data.to_s) && true || false
  end

  def self.string?(data)
    /^["](\"|[^"])*["]$/.match(data.to_s) && true || /^['][^']*[']$/.match(data.to_s) && true || false
  end

  def self.unknown?(data)
    !self.formula?(data) && !self.number?(data) && !self.boolean?(data) && !self.string?(data)
  end

  def self.getRange(range)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(range).to_a[1..-1]
  end

end
