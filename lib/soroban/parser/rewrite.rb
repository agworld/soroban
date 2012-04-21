require 'treetop'

module Treetop
  module Runtime
    class SyntaxNode
      def convert
        if nonterminal?
          value = ""
          elements.each { |element| value << element.convert }
          rewrite(value)
        else
          rewrite(text_value)
        end
      end
      def rewrite(value)
        value
      end
    end
  end
end
