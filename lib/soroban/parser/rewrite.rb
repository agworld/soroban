module Treetop
  module Runtime

    # Each node in the AST produced by the treetop parser implements to_ruby,
    # which allows the Soroban sheet to store the ruby version of the Excel
    # contents of each cell in the sheet (and which also gathers and stores the
    # dependencies that call has on other cells). Each concrete syntax node may
    # override rewrite_ruby and extract_labels.
    class SyntaxNode
      def to_ruby(cell)
        if nonterminal?
          value = ""
          elements.each { |element| value << element.to_ruby(cell) }
          _add_dependency(cell, value)
          rewrite_ruby(value)
        else
          _add_dependency(cell, text_value)
          rewrite_ruby(text_value)
        end
      end

      # Return the ruby version of the Excel value. By default this does
      # nothing; see nodes.rb for concrete implementations. 
      def rewrite_ruby(value)
        value
      end

      # Return either a single label of the form :A1, or an array of labels of
      # the form [:B1, :B2, ...]. This is used to keep track of the dependencies
      # of this particular cell.
      def extract_labels(value)
        nil
      end

    private

      def _add_dependency(cell, value)
        cell.add_dependencies(extract_labels(value))
      end
    end

  end
end
