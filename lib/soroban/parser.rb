require 'treetop'

require 'soroban/parser/rewrite'
require 'soroban/parser/nodes'
require 'soroban/parser/grammar'

module Soroban

  # A Treetop parser for Excel formulas that can generate valid Ruby expression
  # via a rewrite operation, and which can build an array of referenced labels.
  def self.parser
    @@parser ||= SorobanParser.new
  end

end
