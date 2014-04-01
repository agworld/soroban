module Soroban

  # Define a new function.
  def self.define(function_hash)
    @@functions ||= {}
    function_hash.each { |name, callback| @@functions[name] = callback }
  end 

  # Return an array of all defined functions.
  def self.functions
    @@functions.keys.map { |f| f.to_s }
  end

  # Call the named function within the context of the specified sheet.
  def self.call(sheet, name, *args)
    function = name.upcase.to_sym
    raise Soroban::UndefinedError, "No such function '#{function}'" unless @@functions[function]
    sheet.instance_exec(*args, &@@functions[function])
  end

end

require 'soroban/functions/average'
require 'soroban/functions/sum'
require 'soroban/functions/vlookup'
require 'soroban/functions/if'
require 'soroban/functions/and'
require 'soroban/functions/or'
require 'soroban/functions/not'
require 'soroban/functions/max'
require 'soroban/functions/min'
require 'soroban/functions/ln'
require 'soroban/functions/exp'
require 'soroban/functions/count_blank'
require 'soroban/functions/is_blank'
