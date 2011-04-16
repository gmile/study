require_relative 'builder'

class Parser
  attr_writer :input
  attr_reader :output

  RESERVED_WORDS = [
    'absolute',    'and',            'array',
    'asm',         'begin',          'case',
    'constructor', 'const',          'destructor',
    'div',         'downto',         'do',
    'else',        'end',            'file',
    'for',         'function',       'goto',
    'if',          'implementation', 'inherited',
    'inline',      'interface',      'in',
    'label',       'mod',            'nil',
    'not',         'object',         'of',
    'on',          'operator',       'packed',
    'procedure',   'program',        'record',
    'reintroduce', 'repeat',         'self',
    'set',         'shl',            'shr',
    'string',      'then',           'to',
    'type',        'unit',           'until',
    'uses',        'var',            'while',
    'with',        'xor',            'or'
  ]

  TYPES = {
    :ordinar => [
      'integer',  'shortint', 'smallint',
      'longint',  'longword', 'int64',
      'byte',     'word',     'cardinal',
      'qword',    'bytebool',
      'wordbool', 'longbool', 'char'
    ],
    :real => [
      'real',     'single',   'double',
      'exteded',  'comp',     'comp',
      'currency'
    ],
    :boolean => 'boolean',
    :string  => 'string'
  }

  def output
    @output.size > 1 ? @output : @output.flatten
  end

  FILTERS = {
    :comment           => Builder::CommentBuilder.regexp,
    :bracket           => Builder::BracketBuilder.regexp,
    :operation         => Builder::OperationBuilder.regexp,
    :mystring          => Builder::MystringBuilder.regexp,
    :assignement       => Builder::AssignementBuilder.regexp,
    :punctuation       => Builder::PunctuationBuilder.regexp,
    :booleanop         => Builder::BooleanopBuilder.regexp,
    :number            => Builder::NumberBuilder.regexp,
    :bitter_end        => 'end\.',          #TODO: refactor me to where I should belong      extract "." as a reserved word with regexp like ".eof"
    :tordinar          => TYPES[:ordinar].join('|'),
    :treal             => TYPES[:real].join('|'),
    :tboolean          => TYPES[:boolean],
    :tstring           => TYPES[:string],
    :variable          => Builder::VariableBuilder.regexp,
    :undefined         => Builder::UndefinedBuilder.regexp
  }

  ERROR = {
    :input_missing => 'Input string is not given',
    :unknown_token => 'Given token is unknown'
  }

  def initialize string = nil
    @input  = string
    @output = []
  end

  def tokenize
    @output.each_with_index do |line, line_number|
      line.each_with_index do |item, index|
        type = if RESERVED_WORDS.include?(item)
          :reserved_word
        else
          matched_filter = filters.find { |filter| item =~ /#{filter}/ }
          FILTERS.key(matched_filter)
        end

        lexeme = line[index]

        options = {
          :type   => type,
          :lexeme => lexeme,
          :x      => @lines[line_number].index(line[index]),
          :y      => line_number
        }

        line[index] = Builder.const_get("#{type.capitalize}Builder").build(options)

        @lines[line_number][lexeme] = ' '*lexeme.size
      end
    end
  end

  def valid?
    validate
    @undefined.empty?
  end

  # Refactor the division method someday
  # make division without a @lines-proxy
  # see 'case' from tokenize. Any ideas?

  def divide
    return ERROR[:input_missing] if @input.nil?

    @lines = []
    @input.each_line {|line| @lines << line}

    filter = Regexp.new(filters.join('|'))
    @lines.each do |line|
      @output << line.scan(filter)
    end
  end

  private

  def filters
    FILTERS.values
  end

  def validate
    @undefined = output.find_all { |token| token.is_a?(Tokens::Undefined) }
  end
end
