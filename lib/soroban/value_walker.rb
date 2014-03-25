require 'soroban/errors'
require 'soroban/label_walker'

module Soroban

  # An enumerable that allows values of cells in a range to be visited.
  class ValueWalker

    include Enumerable

    # Create a new walker from a supplied range and binding. The binding is
    # required when calculating the value of each visited cell.
    def initialize(range, context)
      @_range, @_binding = range, context
      @_labels = Soroban::LabelWalker.new(range).to_a
    end

    # Yield the value of each cell referenced by the supplied range.
    def each
      @_labels.each { |label| yield eval("get('#{label}')", @_binding) }
    end

    # Get the value of a cell within the range by index. Will raise a RangeError
    # if the index is outside of the range.
    def [](index)
      if index < 0 || index >= @_labels.length
        raise Soroban::RangeError, "Index #{index} falls outside of '#{@_range}'"
      end
      eval("get('#{@_labels[index]}')", @_binding)
    end

    # Set the value of a cell within the range by index. Will raise a RangeError
    # if the index is outside of the range.
    def []=(index, value)
      if index < 0 || index >= @_labels.length
        raise Soroban::RangeError, "Index #{index} falls outside of '#{@_range}'"
      end
      eval("@#{@_labels[index]}.set('#{value}')", @_binding)
      return value
    end

    # Display the range if the user outputs the binding directly
    def to_s
      @_range
    end
    alias inspect to_s

  end

end
