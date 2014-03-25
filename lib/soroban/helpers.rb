require 'soroban/errors'
require 'soroban/value_walker'

module Soroban

  class Helpers
    # Return true if the supplied data represents a formula.
    def self.formula?(data)
      data.to_s.slice(0..0) == '='
    end

    # Return true if the supplied data is a number.
    def self.number?(data)
      Float(data.to_s) && true rescue false
    end

    # Return true if the supplied data is a boolean.
    def self.boolean?(data)
      /^(true|false)$/i.match(data.to_s) && true ||
      false
    end

    # Return true if the supplied data is a string.
    def self.string?(data)
      /^["](\"|[^"])*["]$/.match(data.to_s) && true ||
      /^['][^']*[']$/.match(data.to_s) && true ||
      false
    end

    # Return true if the supplied data is a label.
    def self.label?(data)
      /^([a-zA-Z]+)([\d]+)$/.match(data.to_s) && true ||
      false
    end

    # Return true if the supplied data is a range.
    def self.range?(data)
      /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(data.to_s) && true ||
      false
    end

    # Return true if the supplied data is of no recognised format.
    def self.unknown?(data)
      !formula?(data) &&
      !number?(data) &&
      !boolean?(data) &&
      !string?(data) &&
      !label?(data) &&
      !range?(data)
    end

    # Return the components of a range. This converts something like "A12:C42"
    # to a tuple of the form ["A", "12", "C", "42"]. Will raise a ParseError if
    # the supplied argument is not a valid range.
    def self.getRange(data)
      raise Soroban::ParseError, "invalid #getRange for '#{data}'" if !range?(data)
      /^([a-zA-Z]+)([\d]+):([a-zA-Z]+)([\d]+)$/.match(data.to_s).to_a[1..-1]
    end

    # Return the row and column index of the given label. This converts something
    # like "B42" into [41, 1]. It is a known bug that it does not work for labels
    # of the form "BC42". Will raise a ParseError if the supplied argument is not
    # a valid label.
    def self.getPos(data)
      raise Soroban::ParseError, "invalid #getPos for '#{data}'" if !label?(data)
      match = /^([a-zA-Z]+)([\d]+)$/.match(data.to_s)
      return [match[2].to_i - 1, match[1].upcase[0].ord-"A"[0].ord]
    end

    # Return an array of values for the supplied arguments (which may be numbers, labels and ranges).
    def self.getValues(context, *args)
      args.map { |arg| range?(arg) ? Soroban::ValueWalker.new(arg, context).to_a : arg }.to_a.flatten
    end
  end

end
