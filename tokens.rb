module Tokens
  class Token
    attr_reader :type
    attr_reader :lexeme, :x, :y

    def initialize params
      @type   = params[:type]
      @lexeme = params[:lexeme]
      @x      = params[:x]
      @y      = params[:y]
    end

    def undefined?
      @type == :undefined
    end

    def build
      raise "No type given! Please, provide type when building a Token." unless @type

      case @type
      when :comment     then
      when :bracket     then
      when :operation   then
      when :string      then
      when :assignement then
      when :colon       then
      when :quality     then
      when :number      then
      when :bitter_end  then
      when :user_data   then
      when :undefined   then
      end
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
