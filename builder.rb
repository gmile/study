require_relative 'tokens'

module Builder
  class Builder
    @values = {}

    def self.terminals
      if @values.is_a?(Hash)
        @values.keys
      elsif @values.is_a?(Array)
        @values.map { |value| value.to_sym }
      end
    end
  end

  class BracketBuilder < Builder
    @values = {
      :left_bracket     => '(',
      :right_bracket    => ')',
      :sq_left_bracket  => '[',
      :sq_right_bracket => ']'
    }

    def self.build(options)
      options[:type] = @values.key(options[:lexeme])
      Tokens::Bracket.new(options)
    end

    def self.regexp
      '['+Regexp.escape(@values.values.join)+']'
    end
  end

  class NumberBuilder < Builder
    @values = {
      :real    => '\d+\.\d+',
      :integer => '\d+'
    }

    def self.build(options)
      options[:type] = @values.key(@values.values.find { |v| options[:lexeme] =~ Regexp.new(v) })
      Tokens::Number.new(options)
    end

    def self.regexp
      @values.values.join('|')
    end
  end

  class AlgebraicOperationBuilder < Builder
    @values = {
      :add => '+',
      :sub => '-',
      :mul => '*',
      :div => '/'
    }

    def self.build(options)
      options[:type] = @values.key(options[:lexeme])
      Tokens::AlgebraicOperation.new(options)
    end

    def self.regexp
      '['+Regexp.escape(@values.values.join)+']'
    end
  end

  class VariableBuilder < Builder
    @values = {
      :variable => '\w+',
    }

    def self.build(options)
      options[:type] = @values.keys.first
      Tokens::Variable.new(options)
    end

    def self.regexp
      @values[:variable]
    end
  end

  class AssignementBuilder < Builder
    @values = {
      :assignement => ':='
    }

    def self.build(options)
      options[:type] = @values.keys.first
      Tokens::Assignement.new(options)
    end

    def self.regexp
      @values[:assignement]
    end
  end

  class UndefinedBuilder < Builder
    @values = {
      :undefined => '[^ \t\r\n\v\f]'
    }

    def self.build(options)
      options[:type] = @values.keys.first
      Tokens::Undefined.new(options)
    end

    def self.regexp
      @values[:undefined]
    end
  end

  class MystringBuilder < Builder
    @values = {
      :string => "\'.*?\'"
    }

    def self.build(options)
      options[:type] = @values.keys.first
      Tokens::Mystring.new(options)
    end

    def self.regexp
      @values[:string]
    end
  end

  class PunctuationBuilder < Builder
    @values = {
      :colon     => ':',
      :semicolon => ';',
      :coma      => ',',
      :range     => '..',
      :dot       => '.'
    }

    def self.build(options)
      options[:type] = @values.key(options[:lexeme])
      Tokens::Punctuation.new(options)
    end

    def self.regexp
      '['+@values.reject {|k,v| [:range, :dot].include?(k) }.values.join+']' + '|' + Regexp.escape(@values[:range]).to_s + '|' + Regexp.new(Regexp.escape(@values[:dot])+'$').to_s
    end
  end

  class CommentBuilder < Builder
    @values = {
      :comment => '\{.*\}'
    }

    def self.build(options)
      options[:type] = @values.keys.first
      Tokens::Comment.new(options)
    end

    def self.regexp
      Regexp.new(@values[:comment])
    end
  end

  class BooleanOperationBuilder < Builder
    @values = {
      :not_equal        => '<>',
      :less_or_equal    => '<=',
      :greater_or_equal => '>=',
      :equal            => '=',
      :greater_then     => '>',
      :less_then        => '<'
    }

    def self.build(options)
      options[:type] = @values.key(options[:lexeme])
      Tokens::BooleanOperation.new(options)
    end

    def self.regexp
      Regexp.union(@values.values)
    end
  end

  class ReservedWordBuilder < Builder
    @values = [
                     'and',            'array',
                     'begin',
                     'const',
                     'downto',         'do',
      'else',        'end',
      'for',         'function',
      'if',


      'not',                           'of',

      'procedure',   'program',
                     'repeat',

      'string',      'then',           'to',
      'type',                          'until',
      'uses',        'var',            'while',
                                       'or'
    ]

    def self.build(options)
      options[:type] = options[:lexeme].to_sym
      Tokens::ReservedWord.new(options)
    end

    def self.regexp
      Regexp.new(@values.map{ |i| '\b'+i+'\b' }.join('|'))
    end
  end

  class TypeBuilder < Builder
    @values = {
      :ordinar => ['integer', 'longint', 'byte', 'word'],
      :real    => ['real'],
      :boolean => ['boolean'],
      :string  => ['string']
    }

    def self.build(options)
      options[:type] = @values.select { |k, v| v.include?(options[:lexeme]) }.keys.first
      Tokens::Type.new(options)
    end

    def self.regexp
      Regexp.new(@values.values.flatten.join('|'))
    end
  end
end
