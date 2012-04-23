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
      fc, fr, tc, tr = Soroban::getRange(value) 
      retval = []
      (fc..tc).each do |cc|
        (fr..tr).each do |cr|
          retval << "#{cc}#{cr}".to_sym
        end
      end
      retval
    end
  end

end
