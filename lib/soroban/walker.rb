module Soroban

  class Walker
    include Enumerable
    def initialize(range, binding)
      @binding = binding
      @fc, @fr, @tc, @tr = Soroban::getRange(range)
    end
    def each
      (@fc..@tc).each do |col|
        (@fr..@tr).each do |row|
          yield eval("_#{col}#{row}", @binding)
        end
      end
    end
  end

end
