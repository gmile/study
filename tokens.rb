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

  class Comment < Token
    STRING   = '\{*.*\}'
    PRIORITY = 1

    def to_s
      STRING
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
