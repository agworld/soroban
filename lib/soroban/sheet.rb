require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/label_walker'
require 'soroban/value_walker'
require 'soroban/cell'

module Soroban

  # A container for cells.
  class Sheet
    attr_reader :bindings

    # Creates a new sheet.
    def initialize
      @cells = {}
      @bindings = {}
    end

    # Used for calling dynamically defined functions, and for creating new
    # cells (via `label=`).
    def method_missing(method, *args, &block)
      if match = /^func_(.*)$/i.match(method.to_s)
        return Soroban::call(self, match[1], *args)
      elsif match = /^([a-z][\w]*)=$/i.match(method.to_s)
        return _add(match[1], args[0])
      end
      super
    end

    # Set the contents of one or more cells or ranges.
    def set(options_hash)
      options_hash.each do |label_or_range, contents|
        unless range = Soroban::getRange(label_or_range)
          return _add(label_or_range, contents)
        end
        fc, fr, tc, tr = range
        if fc == tc || fr == tr
          raise ArgumentError, "Expecting an array when setting #{label_or_range}" unless contents.kind_of? Array
          cc, cr = fc, fr
          contents.each do |item|
            set("#{cc}#{cr}" => item)
            cc.next! if fr == tr
            cr.next! if fc == tc
          end
          raise Soroban::RangeError, "Supplied array doesn't match range length" if cc != tc && cr != tr
        else
          raise ArgumentError, "Can only set cells or 1-dimensional ranges of cells"
        end
      end
    end

    # Retrieve the contents of a cell.
    def get(label_or_name)
      label = @bindings[label_or_name] || label_or_name
      _get(label_or_name, eval("@#{label}", binding))
    end

    # Bind one or more named variables to a cell.
    def bind(options_hash)
      options_hash.each do |name, label_or_range|
        if Soroban::range?(label_or_range)
          LabelWalker.new(label_or_range).each do |label|
            next if @cells.keys.include?(label.to_sym)
            raise Soroban::UndefinedError, "Cannot bind '#{name}' to range '#{label_or_range}'; cell #{label} is not defined"
          end
          _bind_range(name, label_or_range)
        else
          unless @cells.keys.include?(label_or_range.to_sym)
            raise Soroban::UndefinedError, "Cannot bind '#{name}' to non-existent cell '#{label_or_range}'"
          end
          _bind(name, label_or_range)
        end
      end
    end

    # Visit each cell in the supplied range, yielding its value.
    def walk(range)
      ValueWalker.new(range, binding)
    end

    # Return a hash of `label => contents` for each cell in the sheet.
    def cells
      Hash[@cells.keys.map { |label| label.to_s }.zip( @cells.keys.map { |label| eval("@#{label}.excel") } )]
    end

    # Return a list of referenced but undefined cells.
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
      raise Soroban::UndefinedError, "Unmet dependencies #{badref.join(', ')} for #{label}" if badref.length > 0
      cell.get
    end

    def _bind(name, label)
      @bindings[name.to_sym] = label.to_sym
      internal = "@#{label}"
      _expose(internal, name)
    end

    def _bind_range(name, range)
      @bindings[name.to_sym] = range.to_s
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          ValueWalker.new("#{range}", binding)
        end
      EOV
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
