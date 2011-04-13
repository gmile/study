module Tokens
  class BooleanOperation
    @values = {
      :not_equal        => '<>',
      :less_or_equal    => '<=',
      :greater_or_equal => '>=',
      :equal            => '=',
      :greater_then     => '>',
      :less_then        => '<'
    }

    def self.regexp
      Regexp.union(@values.values)
    end
  end


  class Comment
    attr_reader :value

    @values = {
      :comment => '\{*.*\}'
    }

    def initialize value
      @value = value
      @type  = @values.key(@values.values.find { |v| value =~ value })
    end

    def self.regexp
      @values[:comment]
    end
  end

  class Token
    attr_reader :type, :lexeme, :x, :y

    def initialize options
      @type   = options[:type]
      @lexeme = options[:lexeme]
      @x      = options[:x]
      @y      = options[:y]
    end
  end

  class Operation < Token
  end

  class Assignement < Token
  end

  class Bracket < Token
  end

  class Variable < Token
  end

  class Mystring < Token
  end

  class Punctuation < Token
  end

  class Number < Token
  end

  class Undefined < Token
  end
end
