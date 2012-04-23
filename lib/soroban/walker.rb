module Soroban

  # An enumerable that allows cells in a range to be visited.
  class Walker

    include Enumerable

    # Create a new walker from a supplied range and binding. The binding is
    # required when calculating the value of each visited cell.
    def initialize(range, binding)
      @binding = binding
      @fc, @fr, @tc, @tr = Soroban::getRange(range)
    end

    # Yield the value of each cell referenced by the supplied range.
    def each
      (@fc..@tc).each do |col|
        (@fr..@tr).each do |row|
          yield eval("@#{col}#{row}.get", @binding)
        end
      end
    end

  end

end
