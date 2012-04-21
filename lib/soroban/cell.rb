require 'soroban/parser'

module Soroban

  class Cell
    attr_reader :excel, :ruby

    def initialize(contents, binding)
      set(contents)
      @binding = binding
      @touched = false
    end

    def get
      return @excel unless Soroban::formula?(@excel)
      raise Soroban::RecursionError, "" if @touched
      @touched = true
      eval(@ruby.slice(1..-1), @binding)
    ensure
      @touched = false
    end

    def set(contents)
      @excel, @ruby = contents, _convert(contents)
    end

  private

    def _convert(contents)
      return contents unless Soroban::formula?(contents)
      tree = Soroban::parser.parse(contents.to_s)
      raise Soroban::ParseError, Soroban::parser.failure_reason if tree.nil?
      tree.convert
    end

  end

end
