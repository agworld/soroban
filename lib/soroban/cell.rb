require 'soroban/parser'

module Soroban

  # Represents a single cell in a sheet. This class is used internally, and
  # isn't exposed to the caller. The cell stores the original string
  # representation of its contents, and the executable Ruby version of same, as
  # generated via a rewrite grammar. Cells also store their dependencies.
  class Cell
    attr_reader :excel, :ruby, :dependencies

    # Cells are initialised with a binding to allow formulas to be executed
    # within the context of the sheet which ownes the cell.
    def initialize(context)
      @dependencies = []
      @binding = context
      @touched = false
    end

    # Set the contents of a cell, and store the executable Ruby version.
    def set(contents)
      contents = contents.to_s
      contents = "'#{contents}'" if Soroban::unknown?(contents)
      @excel, @ruby = contents, _convert(contents)
    end

    # Eval the Ruby version of the string contents within the context of the
    # owning sheet. Will throw Soroban::RecursionError if recursion is detected.
    def get
      raise Soroban::RecursionError, "Loop detected when evaluating '#{@excel}'" if @touched
      @touched = true
      # TODO: cache the value of the cell, and only recalculate it if any of the
      #       dependencies are dirty; also, set outselves as dirty until we've
      #       done that; will need to set the original inputs to non-dirty once
      #       all outputs have been farmed
      eval(@ruby, @binding)
    rescue TypeError, RangeError, ZeroDivisionError
      nil
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
