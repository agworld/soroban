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
      _bind(name, label)
    end

    def get(label_or_name)
      eval("@#{label_or_name}.get", binding)
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
      internal = "@#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{label}?
          #{internal}.ruby
        end
      EOV
      _expose(internal, label)
      instance_variable_set(internal, Cell.new(contents, binding))
    end

    def _bind(name, label)
      @bindings[name.to_sym] = label.to_sym
      internal = "@#{label}"
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{label}?
          "#{name} -> #{label}"
        end
      EOV
      _expose(internal, name)
    end

    def _expose(internal, name)
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          #{internal}.get
        end
        def #{name}=(contents)
          #{internal}.set(contents)
        end
      EOV
    end

  end

end
