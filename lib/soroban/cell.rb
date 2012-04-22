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
      raise Soroban::RecursionError, "" if @touched
      @touched = true
      eval(@ruby, @binding)
    ensure
      @touched = false
    end

    def set(contents)
      contents = contents.to_s
      contents = "'#{contents}'" if Soroban::unknown?(contents)
      @excel, @ruby = contents, _convert(contents)
    end

  private

    def _convert(contents)
      tree = Soroban::parser.parse(contents)
      raise Soroban::ParseError, Soroban::parser.failure_reason if tree.nil?
      tree.convert
    end

  end

end
