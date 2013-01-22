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

      def to_compiled_ruby
        if nonterminal?
          value = ""
          elements.each { |element| value << element.to_compiled_ruby }
          compile_ruby(value)
        else
          compile_ruby(text_value)
        end
      end

      def to_javascript(dependencies)
        if nonterminal?
          value = ""
          elements.each { |element| value << element.to_javascript(dependencies) }
          _add_dependency(dependencies, extract(value))
          rewrite_javascript(value)
        else
          _add_dependency(dependencies, extract(text_value))
          rewrite_javascript(text_value)
        end
      end

      def compile_ruby(value)
        value
      end

      def rewrite_ruby(value)
        value
      end

      def rewrite_javascript(value)
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
