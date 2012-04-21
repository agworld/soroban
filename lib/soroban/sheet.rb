require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/walker'
require 'soroban/cell'

module Soroban

  class Sheet
    include Functions

    attr_reader :cells, :bindings

    def initialize
      @cells = []
      @bindings = {}
    end

    def method_missing(method, *args, &block)
      if match = /^([a-z][\w]*)=$/i.match(method.to_s)
        _add(match[1], args[0])
        return
      end
      super
    end

    def define(function, callback)
    end

    def set(label_or_range, contents)
      _add(label_or_range, contents)
    end

    def bind(name, label)
      unless @cells.include?(label.to_sym)
        raise Soroban::ReferenceError, "Cannot bind '#{name}' to non-existent cell '#{label}'"
      end
      @bindings[name.to_sym] = label.to_sym
      _bind(name, label)
    end

    def get(label_or_name)
      eval("_#{label_or_name}", binding)
    end

    def walk(range)
      Walker.new(range, binding)
    end

    def undefined
      []
    end

  private

    def _add(label, contents)
      @cells << label.to_sym
      internal = "_#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{label}?
          @#{internal}.ruby
        end
        def #{internal}
          @#{internal}.get
        end
      EOV
      _bind(label, label)
      instance_variable_set("@#{internal}", Cell.new(contents, binding))
    end

    def _bind(name, label)
      internal = "_#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          #{internal}
        end
        def #{name}=(contents)
          @#{internal}.set(contents)
        end
      EOV
    end

  end

end
