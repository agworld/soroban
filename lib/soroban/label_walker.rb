module Soroban

  # An enumerable that allows cells in a range to be visited.
  class LabelWalker

    include Enumerable

    # Create a new walker from a supplied range.
    def initialize(range)
      @fc, @fr, @tc, @tr = Soroban::getRange(range)
    end

    # Yield the label of each cell referenced by the supplied range.
    def each
      (@fc..@tc).each do |col|
        (@fr..@tr).each do |row|
          yield "#{col}#{row}"
        end
      end
    end

  end

end
