module Treetop
  module Runtime
    class SyntaxNode

      def to_ruby(dependencies)
        if nonterminal?
          value = ""
          elements.each { |element| value << element.to_ruby(dependencies) }
          _add_dependency(dependencies, extract(value))
          rewrite_ruby(value)
        else
          _add_dependency(dependencies, extract(text_value))
          rewrite_ruby(text_value)
        end
      end

      def rewrite_ruby(value)
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
