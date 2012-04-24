module Soroban

  # An enumerable that allows cells in a range to be visited.
  class ValueWalker

    include Enumerable

    # Create a new walker from a supplied range and binding. The binding is
    # required when calculating the value of each visited cell.
    def initialize(range, context)
      @range, @binding = range, context
      @walker = LabelWalker.new(range)
    end

    # Yield the value of each cell referenced by the supplied range.
    def each
      @walker.each { |label| yield eval("get('#{label}')", @binding) }
    end

    # Retrieve the value of a cell within the range by index
    def [](index)
      labels = @walker.to_a
      if index < 0 || index >= labels.length
        raise Soroban::RangeError, "Index #{index} falls outside of '#{@range}'"
      end
      eval("get('#{labels[index]}')", @binding)
    end

    # Set the value of a cell within the range by index
    def []=(index, value)
      count = 0
      @walker.each do |label|
        if index == count
          eval("@#{label}.set('#{value}')", @binding)
          return value
        end
        count += 1
      end
      raise Soroban::RangeError, "Index #{index} falls outside of '#{@range}'"
    end

    # Display the range if the user outputs the binding directly
    def to_s
      @range
    end
    alias inspect to_s

  end

end
