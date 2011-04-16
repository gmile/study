module Tokens
  class Token
    attr_reader :type, :lexeme, :x, :y

    def initialize options
      @type   = options[:type]
      @lexeme = options[:lexeme]
      @x      = options[:x]
      @y      = options[:y]
    end
  end

  class Operation   < Token; end
  class Assignement < Token; end
  class Bracket     < Token; end
  class Variable    < Token; end
  class Mystring    < Token; end
  class Punctuation < Token; end
  class Number      < Token; end
  class Undefined   < Token; end
  class Comment     < Token; end
  class Booleanop   < Token; end
end
