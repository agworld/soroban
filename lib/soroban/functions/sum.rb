module Soroban

  module Functions

    def func_sum(range)
      walk(range).reduce(:+)
    end

  end

end
