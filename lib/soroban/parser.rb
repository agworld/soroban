require 'treetop'

require 'soroban/parser/grammar'
require 'soroban/parser/nodes'
require 'soroban/parser/rewrite'

module Soroban
  def self.parser
    @@parser ||= SorobanParser.new
  end
end
