require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/label_walker'
require 'soroban/value_walker'
require 'soroban/tabulator'
require 'soroban/cell'

module Soroban

  # A container for cells.
  class Sheet
    attr_reader :bindings

    # Creates a new sheet.
    def initialize(logger=nil)
      @logger = logger
      @cells = {}
      @compiled = {}
      @changes = Hash.new{ |h, k| h[k] = Set.new }
      @bindings = {}
    end

    def factory(name)
      eval(self.to_ruby(name), TOPLEVEL_BINDING)
      Object::const_get('Soroban').const_get('Model').const_get(name).new
    end

    # Return a string containing a ruby class that implements the sheet. You can
    # call eval() on this string to create the class, which you can then
    # instantiate. Set inputs on the instance and read outputs off.
    def to_ruby(class_name)
      data = []
      data << "module Soroban"
      data << "module Model"
      data << "class #{class_name}"
      data << "  def initialize"
      data << "    @binds = {"
      data << bindings.map do |name, cell|
        "      '#{name}' => :#{cell}"
      end.join(",\n")
      data << "    }"
      data << "    @cache = {}"
      data << "    @cells = {"
      data << @compiled.map do |label, cell|
        "      :#{label} => lambda { @cache[:#{label}] ||= #{cell.to_compiled_ruby} }"
      end.join(",\n")
      data << "    }"
      data << "  end"
      data << "  def clear"
      data << "    @cache.clear"
      data << "  end"
      data << "  def get(name)"
      data << "    @cells[@binds[name]].call"
      data << "  end"
      data << "  def set(name, value)"
      data << "    self.clear"
      data << "    @cells[@binds[name]] = lambda { @cache[@binds[name]] ||= value }"
      data << "  end"
      bindings.each do |name, cell|
        data << "  def #{name}"
        data << "    get('#{name}')"
        data << "  end"
        data << "  def #{name}=(value)"
        data << "    set('#{name}', value)"
        data << "  end"
      end
      data << "end"
      data << "end"
      data << "end"
      puts data.join("\n")
      data.join("\n")
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
        _debug("setting '#{label_or_range}' to '#{contents}'")
        unless range = Soroban::getRange(label_or_range)
          _add(label_or_range, contents)
          next
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
      label = @bindings[label_or_name.to_sym] || label_or_name
      _debug("retrieving '#{label_or_name}' from '#{label}'}")
      if Soroban::range?(label)
        walk(label)
      else
        _get(label_or_name, eval("@#{label}", binding))
      end
    end

    # Bind one or more named variables to a cell.
    def bind(options_hash)
      options_hash.each do |name, label_or_range|
        _debug("binding '#{name}' to '#{label_or_range}'}")
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
      labels = @cells.keys.map { |label| label.to_sym }
      contents = labels.map { |label| eval("@#{label}.excel") }
      Hash[labels.zip(contents)]
    end

    # Return a list of referenced but undefined cells.
    def missing
      @cells.values.flatten.uniq - @cells.keys
    end

  private

    def _debug(message)
      return if @logger.nil?
      @logger.debug "SOROBAN: #{message}"
    end

    def _link(name, dependencies)
      dependencies.each { |target| @changes[target] << name if name != target }
    end

    def _unlink(name, dependencies)
      dependencies.each { |target| @changes[target].delete(name) }
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
      cell = Cell.new(binding)
      @compiled[label] = cell
      _set(label, cell, contents)
      instance_variable_set(internal, cell)
    end

    def _set(label_or_name, cell, contents)
      label = label_or_name.to_sym
      name = @bindings[label] || label
      _unlink(name, cell.dependencies)
      cell.set(contents)
      @cells[name] = cell.dependencies
      _link(name, cell.dependencies)
      _clear(name)
    end

    def _clear(name)
      @changes[name].each do |target|
        next unless @cells.has_key?(target)
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
