module Soroban

  class Formula < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      value.gsub(/^= */, '')
    end
  end

  class Identifier < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "@#{value}.get"
    end
    def extract(value)
      value.to_sym
    end
  end

  class IntegerValue < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "#{value.to_f}"
    end
  end

  class FloatValue < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "#{value.to_f}"
    end
  end

  class Function < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      match = /^([^(]*)(.*)$/.match(value)
      "func_#{match[1].downcase}#{match[2]}"
    end
  end

  class Pow < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "**"
    end
  end

  class Equal < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "=="
    end
  end

  class NotEqual < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "!="
    end
  end

  class Label < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      value.gsub('$', '')
    end
  end

  class Range < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "'#{value}'"
    end
    def extract(value)
      LabelWalker.new(value).map { |label| "#{label}".to_sym }
    end
  end

end
