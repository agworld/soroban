require 'soroban/parser'

module Soroban

  class Cell
    attr_reader :excel, :ruby, :dependencies

    def initialize(binding)
      @dependencies = []
      @binding = binding
      @touched = false
    end

    def set(contents)
      contents = contents.to_s
      contents = "'#{contents}'" if Soroban::unknown?(contents)
      @excel, @ruby = contents, _convert(contents)
    end

    def get
      raise Soroban::RecursionError, "Loop detected when evaluating '#{@excel}'" if @touched
      @touched = true
      eval(@ruby, @binding)
    ensure
      @touched = false
    end

  private

    def _convert(contents)
      tree = Soroban::parser.parse(contents)
      raise Soroban::ParseError, Soroban::parser.failure_reason if tree.nil?
      tree.convert(@dependencies.clear)
    end

  end

end
