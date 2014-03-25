unless defined?(Set)
  require 'set'
end

require 'soroban/errors'
require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/cell'
require 'soroban/label_walker'
require 'soroban/value_walker'

module Soroban

  # A container for cells. This is what the end user of Soroban will manipulate,
  # either directly or via an importer that returns a Sheet instance.
  class Sheet
    attr_reader :bindings

    # Creates a new sheet.
    def initialize(logger=nil)
      @_logger = logger
      @_cells = {}
      @_changes = Hash.new { |h, k| h[k] = Set.new }
      @bindings = {}
    end

    # Used for calling dynamically defined functions, and for creating new
    # cells (via `label=`).
    def method_missing(method, *args, &block)
      if match = /^func_(.*)$/i.match(method.to_s)
        return Soroban::Functions.call(self, match[1], *args)
      elsif match = /^([a-z][\w]*)=$/i.match(method.to_s)
        return _add(match[1], args[0])
      end
      super
    end

    # Set the contents of one or more cells or ranges.
    def set(options_hash)
      options_hash.each do |label_or_range, contents|
        _debug("setting '#{label_or_range}' to '#{contents}'")
        unless Soroban::Helpers.range?(label_or_range)
          _add(label_or_range, contents)
          next
        end
        fc, fr, tc, tr = Soroban::Helpers.getRange(label_or_range)
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
      label = @bindings[label_or_name.to_sym] || label_or_name
      _debug("retrieving '#{label_or_name}' from '#{label}'}")
      if Soroban::Helpers.range?(label)
        walk(label)
      else
        _get(label_or_name, eval("@#{label}", binding))
      end
    end

    # Bind one or more named variables to a cell.
    def bind(options_hash)
      options_hash.each do |name, label_or_range|
        _debug("binding '#{name}' to '#{label_or_range}'}")
        if Soroban::Helpers.range?(label_or_range)
          Soroban::LabelWalker.new(label_or_range).each do |label|
            next if @_cells.has_key?(label.to_sym)
            raise Soroban::UndefinedError, "Cannot bind '#{name}' to range '#{label_or_range}'; cell #{label} is not defined"
          end
          _bind_range(name, label_or_range)
        else
          unless @_cells.has_key?(label_or_range.to_sym)
            raise Soroban::UndefinedError, "Cannot bind '#{name}' to non-existent cell '#{label_or_range}'"
          end
          _bind(name, label_or_range)
        end
      end
    end

    # Visit each cell in the supplied range, yielding its value.
    def walk(range)
      Soroban::ValueWalker.new(range, binding)
    end

    # Return a hash of `label => contents` for each cell in the sheet.
    def cells
      labels = @_cells.keys.map(&:to_sym)
      contents = labels.map { |label| eval("@#{label}.excel") }
      Hash[labels.zip(contents)]
    end

    # Return an array of referenced but undefined cells.
    def missing
      (@_cells.values.reduce(:|) - @_cells.keys).to_a
    end

  private

    def _debug(message)
      return if @_logger.nil?
      @_logger.debug "SOROBAN: #{message}"
    end

    def _link(name, dependencies)
      dependencies.each { |target| @_changes[target] << name if name != target }
    end

    def _unlink(name, dependencies)
      dependencies.each { |target| @_changes[target].delete(name) }
    end

    def _add(label, contents)
      name = @bindings[label.to_sym] || label
      if cells.has_key?(name)
        cell = eval("@#{name}", binding)
        cell.set(contents)
        return
      end
      internal = "@#{label}"
      _expose(internal, label)
      cell = Soroban::Cell.new(binding)
      _set(label, cell, contents)
      instance_variable_set(internal, cell)
    end

    def _set(label_or_name, cell, contents)
      label = label_or_name.to_sym
      name = @bindings[label] || label
      _unlink(name, cell.dependencies)
      cell.set(contents)
      @_cells[name] = cell.dependencies
      _link(name, cell.dependencies)
      _clear(name)
    end

    def _clear(name)
      @_changes[name].each do |target|
        next unless @_cells.has_key?(target)
        begin
          eval("@#{target.to_s}.clear")
          _clear(target)
        rescue
        end
      end
    end

    def _get(label_or_name, cell)
      label = label_or_name.to_sym
      name = @bindings[label] || label
      badref = @_cells[name] & missing
      raise Soroban::UndefinedError, "Unmet dependencies #{badref.to_a.join(', ')} for #{label}" if badref.length > 0
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
          walk("#{range}")
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
