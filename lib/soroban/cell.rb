module Soroban

  class Cell
    attr_reader :value
    def initialize(value, binding)
      @value, @binding = value, binding
      @touched = false
    end
    def get
      return @value unless Soroban::formula?(@value)
      raise Soroban::RecursionError, "" if @touched
      @touched = true
      eval(@value.slice(1..-1), @binding)
    ensure
      @touched = false
    end
    def set(value)
      @value = value
    end
  end

end
