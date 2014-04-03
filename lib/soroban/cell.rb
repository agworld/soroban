unless defined?(Set)
  require 'set'
end

require 'soroban/errors'
require 'soroban/helpers'
require 'soroban/parser'

module Soroban

  # Represents a single cell in a sheet. This class is used internally, and
  # isn't exposed to the caller. The cell stores the original string
  # representation of its contents, and the executable Ruby version of same, as
  # generated via a rewrite grammar. Cells also store their dependencies.
  class Cell
    attr_reader :excel, :ruby, :dependencies

    # Cells are initialised with a binding to allow formulas to be executed
    # within the context of the sheet which owns the cell.
    def initialize(context)
      @dependencies = Set.new
      @excel = nil
      @ruby = nil
      @_binding = context
      @_touched = false
      @_value = nil
      @_tree = nil
    end

    # Set the contents of a cell, and store the executable Ruby version. A
    # Soroban::ParseError will be raised if an attempt is made to assign a value
    # that isn't recognised by the Excel parser (although in most cases this
    # should be treated as if you've passed in a string value). Note that
    # assigning to the cell may cause its computed value to change; call #get to
    # retrieve that. Note also that #set calls #clear internally to force
    # recomputation of this value on the next #get call.
    def set(contents)
      contents = contents.to_s
      contents = "'#{contents}'" if Soroban::Helpers.unknown?(contents)
      clear
      @excel = contents
      @_tree = Soroban::Parser.instance.parse(@excel)
      raise Soroban::ParseError, Soroban::Parser.instance.failure_reason if @_tree.nil?
      @dependencies.clear
      @ruby = @_tree.to_ruby(self)
    end

    # Clear the cached value of a cell to force it to be recalculated. This
    # should be unnecessary to call explicitly.
    def clear
      @_value = nil
    end

    # Compute the value of the cell by evaluating the #ruby version of its
    # contents within the context of the owning sheet. Will raise a
    # Soroban::RecursionError if recursion is detected.
    def get
      raise Soroban::RecursionError, "Loop detected when evaluating '#{@excel}'" if @_touched
      @_touched = true
      return @_value if @_value
      @_value = eval(@ruby, @_binding)
      _normalise_value!
      return @_value
    rescue TypeError => e
      @_value = nil
    rescue RangeError => e
      @_value = nil
    rescue ZeroDivisionError => e
      @_value = nil
    ensure
      @_touched = false
    end

    # Used by the parser to add information about which cells the value of this
    # particular cell is dependent on. May pass in a single cell label or a
    # collection of cells labels. The dependencies are stored as a Set, so the
    # best way of adding the labels is to ensure they're converted to an
    # enumerable (with [labels].flatten), and then to assign the union of the
    # Set with that enumerable (with |=)
    def add_dependencies(labels)
      @dependencies |= [labels].flatten unless labels.nil?
    end

    private

    def _normalise_value!
      return if @_value.respond_to?( :length ) && @_value.length > 0

      begin
        @_value = @_value.to_f
      rescue NoMethodError
        # Do not mutate value
      end
    end
  end

end
