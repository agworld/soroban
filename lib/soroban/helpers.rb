require 'soroban/parser'

module Soroban

  def self.parser
    @@parser ||= SorobanParser.new
  end

  def self.formula?(data)
    return false unless data.kind_of?(String)
    data.slice(0..0) == '='
  end

  def self.getRange(range)
    /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(range).to_a[1..-1]
  end

end
