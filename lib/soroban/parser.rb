require 'treetop'

require 'soroban/parser/rewrite'
require 'soroban/parser/nodes'
require 'soroban/parser/grammar'

module Soroban

  # A Treetop parser for Excel formulas that can generate valid Ruby expression
  # via a rewrite operation, and which can build an array of referenced labels.
  def self.parser
    if ENV["RUBY_ENV"] == "test"
      return @parser if @parser
      path = Pathname.new( File.dirname( __FILE__ ) ).join( "parser/grammar" ).to_s
      Treetop.load( path )
      @parser ||= SorobanParser.new
    else
      @@parser ||= SorobanParser.new
    end
  end

end
