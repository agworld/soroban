require 'treetop'

require 'soroban/parser/rewrite'
require 'soroban/parser/nodes'
require 'soroban/parser/grammar'

module Soroban
  def self.parser
    @@parser ||= SorobanParser.new
  end
end
