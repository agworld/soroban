module Soroban

  # An enumerable that splits a range of cells into an nxm array
  class Tabulator

    include Enumerable

    # Create a new walker from a supplied range.
    def initialize(range)
      @fc, @fr, @tc, @tr = Soroban::getRange(range)
    end

    def get
      row = []
      cols = [row]
      col_ref, row_ref = @fc, @fr
      while true do
        row << "#{col_ref}#{row_ref}".to_sym
        break if row_ref == @tr && col_ref == @tc
        if row_ref == @tr
          row = []
          cols << row
          row_ref = @fr
          col_ref = col_ref.next
        else
          row_ref = row_ref.next
        end
      end
      cols
    end

  end

end
