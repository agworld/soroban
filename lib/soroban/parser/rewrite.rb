module Treetop
  module Runtime
    class SyntaxNode

      def convert(dependencies)
        if nonterminal?
          value = ""
          elements.each { |element| value << element.convert(dependencies) }
          _add_dependency(dependencies, extract(value))
          rewrite(value)
        else
          _add_dependency(dependencies, extract(text_value))
          rewrite(text_value)
        end
      end

      def rewrite(value)
        value
      end

      def extract(value)
      end

    private

      def _add_dependency(dependencies, value)
        return if value.nil?
        dependencies << value
        dependencies.flatten!
        dependencies.compact!
        dependencies.uniq!
      end

    end
  end
end
