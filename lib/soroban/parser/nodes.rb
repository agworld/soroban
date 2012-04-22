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
  end

  class Function < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      match = /^([^(]*)(.*)$/.match(value)
      "func_#{match[1].downcase.slice(1..-5)}#{match[2]}"
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
  end

end
