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

  GRAMMAR = <<'GRAMMAR'
grammar Soroban
  rule formula
    '=' space? logical / string / number / boolean
  end
  rule logical
    and ( space? 'or' space? and )*
  end
  rule and
    truthval ( space? 'and' space? truthval )*
  end
  rule truthval
    comparison / '(' space? logical space? ')' / boolean
  end
  rule boolean
    'true' / 'false' / 'TRUE' / 'FALSE'
  end
  rule comparison
    expression ( space? comparator space? expression )*
  end
  rule comparator
    '=' <Equal> / '<>' <NotEqual> / '>=' / '<=' / '>' / '<'
  end
  rule expression
    multiplicative ( space? additive_operator space? multiplicative )*
  end
  rule additive_operator
    '+' / '-'
  end
  rule multiplicative
    value ( space? multiplicative_operator space? value )*
  end
  rule multiplicative_operator
    '^' <Pow> / '*' / '/'
  end
  rule value
    ( function / '(' space? expression space? ')' / range / number / identifier / string / '-' value )
  end
  rule function
    identifier '(' space? arguments? space? ')' <Function>
  end
  rule arguments
    logical ( space? ',' space? logical )*
  end
  rule number
    float / integer
  end
  rule float
    [0-9]* '.' [0-9]+
  end
  rule integer
    [0-9]+
  end
  rule identifier
    [a-zA-Z] [a-zA-Z0-9]* <Identifier>
  end
  rule label
    [A-Za-z]+ [1-9] [0-9]* <Label> / '$' [A-Za-z]+ '$' [1-9] [0-9]* <Label>
  end
  rule string
    '"' ('\"' / !'"' .)* '"' / "'" [^']* "'"
  end
  rule range
    label ':' label <Range>
  end
  rule space
    [\s]+
  end
end
GRAMMAR
end
