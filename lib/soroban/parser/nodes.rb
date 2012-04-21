module Soroban

  class Identifier < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      "_#{value}"
    end
  end

  class Function < Treetop::Runtime::SyntaxNode
    def rewrite(value)
      match = /^([^(]*)(.*)$/.match(value)
      "func#{match[1].downcase}#{match[2]}"
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
