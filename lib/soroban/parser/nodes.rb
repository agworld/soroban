module Soroban

  class Formula < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      value.gsub(/^= */, '')
    end
    alias :compile_ruby :rewrite_ruby
  end

  class Identifier < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "@#{value}.get"
    end
    def compile_ruby(value)
      "@cells[:#{value}].call"
    end
    def extract(value)
      value.to_sym
    end
  end

  class IntegerValue < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "#{value.to_f}"
    end
    alias :compile_ruby :rewrite_ruby
  end

  class FloatValue < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "#{value.to_f}"
    end
    alias :compile_ruby :rewrite_ruby
  end

  class Function < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      match = /^([^(]*)(.*)$/.match(value)
      "func_#{match[1].downcase}#{match[2]}"
    end
    def compile_ruby(value)
      match = /^([A-Z]+)\((.*)\)$/.match(value)
      name, args = match[1], match[2].split(',')
      case name
        when 'VLOOKUP'
          find, table, column, _ = args
          table = table[1...-1]
          column = column.to_i
          table_key = "'#{table}_#{column}'"
          code = []
          code << "begin"
          code << "        @cache[#{table_key}] ||= {"
          cols = Tabulator.new(table).get
          lookup = Hash[cols[0].zip(cols[column-1])]
          code << lookup.map do |key, val|
            "          @cells[:#{key}].call => @cells[:#{val}].call"
          end.join(",\n")
          code << "        }"
          code << "        @cache[#{table_key}][#{find}] || 0.0"
          code << "      end"
          code.join("\n")
        else
          value
      end
    end
  end

  class Pow < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "**"
    end
    alias :compile_ruby :rewrite_ruby
  end

  class Equal < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "=="
    end
    alias :compile_ruby :rewrite_ruby
  end

  class NotEqual < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "!="
    end
    alias :compile_ruby :rewrite_ruby
  end

  class Label < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      value.gsub('$', '')
    end
    alias :compile_ruby :rewrite_ruby
  end

  class Range < Treetop::Runtime::SyntaxNode
    def rewrite_ruby(value)
      "'#{value}'"
    end
    alias :compile_ruby :rewrite_ruby
    def extract(value)
      LabelWalker.new(value).map { |label| "#{label}".to_sym }
    end
  end

end
