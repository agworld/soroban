require 'soroban/helpers'

module Soroban

  # An enumerable that allows the labels for cells in a range to be visited.
  class LabelWalker
    include Enumerable

    # Create a new walker from a supplied range.
    def initialize(range)
      @_fc, @_fr, @_tc, @_tr = Soroban::Helpers.getRange(range)
    end

    # Yield the label of each cell referenced by the supplied range. For a range
    # of the form "A1:B4", this will yield "A1", "A2", "A3", ..., "B3", "B4".
    def each
      col, row = @_fc, @_fr
      while true do
        yield "#{col}#{row}"
        break if row == @_tr && col == @_tc
        if row == @_tr
          row = @_fr
          col = col.next
        else
          row = row.next
        end
      end
    end
  end

end
