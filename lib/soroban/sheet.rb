require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/parser'
require 'soroban/walker'
require 'soroban/cell'

module Soroban

  class Sheet
    include Functions

    def initialize
      @parser = SorobanParser.new
    end

    def method_missing(method, *args, &block)
      # TODO: handle adding a function
      if match = /^([a-z][\w]*)=$/i.match(method.to_s)
        _add(match[1], args[0])
        return
      end
      super
    end

    def define(function, callback)
      # TODO: store a lambda
    end

    def set(label_or_range, contents)
      # TODO: if a range is specified, contents must be an array or hash
      _add(label_or_range, contents)
    end

    def bind(name, label)
      _bind(name, label)
    end

    def get(label_or_name)
      eval("_#{label_or_name}", binding)
    end

    def walk(range)
      Walker.new(range, binding)
    end

    def cells
    end

    def bindings
    end

    def functions
    end

    def undefined
    end

  private

    def _add(label, contents)
      internal = "_#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{label}?
          @#{internal}.contents
        end
        def #{internal}
          @#{internal}.get
        end
      EOV
      _bind(label, label)
      instance_variable_set("@#{internal}", Cell.new(_convert(contents), binding))
    end

    def _bind(name, label)
      internal = "_#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          #{internal}
        end
        def #{name}=(contents)
          @#{internal}.set(_convert(contents))
        end
      EOV
    end

    def _convert(contents)
      return contents unless Soroban::formula?(contents)
      tree = @parser.parse(contents.to_s)
      raise Soroban::ParseError, @parser.failure_reason if tree.nil?
      tree.convert
    end

  end

end
