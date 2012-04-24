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
      col, row = @fc, @fr
      while true do
        yield "#{col}#{row}"
        break if row == @tr && col == @tc
        if row == @tr
          row = @fr
          col = col.next
        else
          row = row.next
        end
      end
    end

  end

end
