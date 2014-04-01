require 'soroban/parser'

module Soroban

  # Represents a single cell in a sheet. This class is used internally, and
  # isn't exposed to the caller. The cell stores the original string
  # representation of its contents, and the executable Ruby version of same, as
  # generated via a rewrite grammar. Cells also store their dependencies.
  class Cell
    attr_reader :excel, :javascript, :dependencies

    # Cells are initialised with a binding to allow formulas to be executed
    # within the context of the sheet which owns the cell.
    def initialize(context)
      @dependencies = []
      @binding = context
      @touched = false
      @value = nil
    end

    def to_compiled_ruby
      @tree.to_compiled_ruby
    end

    # Set the contents of a cell, and store the executable Ruby version.
    def set(contents)
      contents = contents.to_s
      contents = "'#{contents}'" if Soroban::unknown?(contents)
      clear
      @excel = contents
      @tree = Soroban::parser.parse(@excel)
      raise Soroban::ParseError, Soroban::parser.failure_reason if @tree.nil?
      @ruby = _to_ruby
    end

    # Clear the cached value of a cell to force it to be recalculated
    def clear
      @value = nil
    end

    # Eval the Ruby version of the string contents within the context of the
    # owning sheet. Will throw Soroban::RecursionError if recursion is detected.
    def get
      raise Soroban::RecursionError, "Loop detected when evaluating '#{@excel}'" if @touched
      @touched = true
      return @value if @value
      @value = eval(@ruby, @binding)
      _normalise_value!
      return @value
    rescue TypeError => e
      @value = nil
    rescue RangeError => e
      @value = nil
    rescue ZeroDivisionError => e
      @value = nil
    ensure
      @touched = false
    end

  private

    def _normalise_value!
      return if @value.respond_to?( :length ) && @value.length > 0

      begin
        @value = @value.to_f
      rescue NoMethodError
        # Do not mutate value
      end
    end

    def _to_ruby
      @tree.to_ruby(@dependencies.clear)
    end

    def _to_javascript
      @tree.to_javascript(@dependencies.clear)
    end

  end

end
