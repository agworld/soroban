require 'soroban/errors'
require 'soroban/helpers'

module Soroban

  class Functions
    # Define one or more functions by passing in a hash mapping function name to
    # the lambda that computes the function's value.
    def self.define(function_hash)
      @@_functions ||= {}
      function_hash.each do |name, callback|
        @@_functions[name.to_s.upcase.to_sym] = callback
      end
    end 

    # Return an array of all defined functions.
    def self.all
      @@_functions.keys.map(&:to_s).to_a.sort
    end

    # Call the named function within the context of the specified sheet, supplying
    # some number of arguments (which is a property of the function, and therefore
    # given as a splat here).
    def self.call(sheet, name, *args)
      callback = @@_functions[name.to_s.upcase.to_sym]
      raise Soroban::UndefinedError, "No such function '#{name}'" if callback.nil?
      sheet.instance_exec(*args, &callback)
    end
  end

end

require 'soroban/functions/and'
require 'soroban/functions/average'
require 'soroban/functions/exp'
require 'soroban/functions/if'
require 'soroban/functions/ln'
require 'soroban/functions/max'
require 'soroban/functions/min'
require 'soroban/functions/not'
require 'soroban/functions/or'
require 'soroban/functions/sum'
require 'soroban/functions/vlookup'
require 'soroban/functions/count_blank'
require 'soroban/functions/is_blank'
