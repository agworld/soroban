require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/walker'
require 'soroban/cell'

module Soroban

  class Sheet
    attr_reader :bindings

    def initialize
      @cells = {}
      @bindings = {}
    end

    def method_missing(method, *args, &block)
      if match = /^func_(.*)$/i.match(method.to_s)
        return Soroban::call(self, match[1], *args)
      elsif match = /^([a-z][\w]*)=$/i.match(method.to_s)
        return _add(match[1], args[0])
      end
      super
    end

    def set(label_or_range, contents)
      unless range = Soroban::getRange(label_or_range)
        return _add(label_or_range, contents)
      end
      fc, fr, tc, tr = range
      if fc == tc || fr == tr
        raise ArgumentError, "Expecting an array when setting #{label_or_range}" unless contents.kind_of? Array
        cc, cr = fc, fr
        contents.each do |item|
          set("#{cc}#{cr}", item)
          cc.next! if fr == tr
          cr.next! if fc == tc
        end
        raise Soroban::ReferenceError, "Supplied array doesn't match range length" if cc != tc && cr != tr
      else
        raise ArgumentError, "Can only set cells or 1-dimensional ranges of cells"
      end
    end

    def get(label_or_name)
      _get(label_or_name, eval("@#{label_or_name}", binding))
    end

    def bind(name, label)
      unless @cells.keys.include?(label.to_sym)
        raise Soroban::ReferenceError, "Cannot bind '#{name}' to non-existent cell '#{label}'"
      end
      _bind(name, label)
    end

    def walk(range)
      Walker.new(range, binding)
    end

    def cells
      @cells.keys.map { |label| label.to_s }.zip( @cells.keys.map { |label| eval("@#{label}.excel") } )
    end

    def missing
      @cells.values.map.flatten.uniq - @cells.keys
    end

  private

    def _add(label, contents)
      internal = "@#{label}"
      _expose(internal, label)
      cell = Cell.new(binding)
      _set(label, cell, contents)
      instance_variable_set(internal, cell)
    end

    def _set(label, cell, contents)
      cell.set(contents)
      @cells[label.to_sym] = cell.dependencies
    end

    def _get(label_or_name, cell)
      label = label_or_name.to_sym
      name = @cells[label] ? label : @bindings[label]
      badref = @cells[name] & missing
      raise Soroban::ReferenceError, "Unmet dependencies #{badref.join(', ')} for #{label}" if badref.length > 0
      cell.get
    end

    def _bind(name, label)
      @bindings[name.to_sym] = label.to_sym
      internal = "@#{label}"
      _expose(internal, name)
    end

    def _expose(internal, name)
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          _get("#{name}", #{internal})
        end
        def #{name}=(contents)
          _set("#{name}", #{internal}, contents)
        end
      EOV
    end

  end

end
