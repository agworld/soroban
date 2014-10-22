module Soroban
  module Excel

    class Formula < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        value.gsub(/^= */, '')
      end
    end

    class Identifier < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "@#{value.gsub('$', '')}.get"
      end
      def extract_labels(value)
        value.gsub('$', '').to_sym
      end
    end

    class IntegerValue < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "#{value.to_f}"
      end
    end

    class FloatValue < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "#{value.to_f}"
      end
    end

    class Function < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        match = /^([^(]*)(.*)$/.match(value)
        "func_#{match[1].downcase}#{match[2]}"
      end
    end

    class Pow < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "**"
      end
    end

    class Equal < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "=="
      end
    end

    class NotEqual < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "!="
      end
    end

    class Label < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        value.gsub('$', '')
      end
    end

    class Range < Treetop::Runtime::SyntaxNode
      def rewrite_ruby(value)
        "'#{value}'"
      end
      def extract_labels(value)
        Soroban::LabelWalker.new(value).map { |label| "#{label}".to_sym }
      end
    end

  end
end
