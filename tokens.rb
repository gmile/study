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

  class BooleanOperation < Token
    attr_reader :values

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

  class Brackets < Token
    STRING   = '[()]'
    PRIORITY = 2
  end

  class Operations < Token
    STRING   = '[/+\-*]'
    PRIORITY = 3
  end

  class String < Token
    STRING   = "\'.*?\'"
    PRIORITY = 4
  end

  class Operations < Token
    STRING   = '[/+\-*]'
    PRIORITY = 5
  end
end
