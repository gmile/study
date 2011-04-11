module Tokens
  class Token
    attr_reader :type
    attr_reader :value, :x, :y

    def initialize params
      @type  = params[:type]
      @value = params[:value]
      @x     = params[:x]
      @y     = params[:y]
    end

    def undefined?
      @type == :undefined
    end

    def comment?
      @type == :comment
    end
  end

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

  class AlgebraicOperation
    @values = {
      :add => '+',
      :sub => '-',
      :mul => '*',
      :div => '/'
    }

    def self.regexp
      '['+Regexp.escape(@values.values.join)+']'
    end
  end

  class Assignement
    @values = {
      :assign => ':='
    }

    def self.regexp
      @values[:assign]
    end
  end

  class Comment
    @values = {
      :comment => '\{*.*\}'
    }

    def self.regexp
      @values[:comment]
    end
  end

  class Bracket
    @values = {
      :left  => '(',
      :right => ')'
    }

    def self.regexp
      '['+@values.values.join+']'
    end
  end

  class MyString
    @values = {
      :string => ''
    }

    def self.regexp
      "\'.*?\'"
    end
  end

  class Punctuation
    @values = {
      :colon     => ':',
      :semicolon => ';'
    }

    def self.regexp
      '['+@values.values.join+']'
    end
  end

  class Number
    @values = {
      :real    => '\d+\.\d+',
      :integer => '\d+'
    }

    def self.regexp
      @values.values.join('|')
    end
  end

  class Variable
    @values = {
      :var => '\w+',
    }

    def self.regexp
      @values[:var]
    end
  end

  class Undefined
    @values = {
      :undefined => '[^ \t\r\n\v\f]'
    }

    def self.regexp
      @values[:undefined]
    end
  end
end
