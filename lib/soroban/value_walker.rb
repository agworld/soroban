module Soroban

  # An enumerable that allows cells in a range to be visited.
  class ValueWalker

    include Enumerable

    # Create a new walker from a supplied range and binding. The binding is
    # required when calculating the value of each visited cell.
    def initialize(range, binding)
      @binding = binding
      @walker = LabelWalker.new(range)
    end

    # Yield the value of each cell referenced by the supplied range.
    def each
      @walker.each { |label| yield eval("@#{label}.get", @binding) }
    end

  end

end
