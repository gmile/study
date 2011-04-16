require_relative 'builder'

class Parser
  attr_writer :input
  attr_reader :output

  # TODO: add '.' as a reserved word + test for it

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
    :reserved_word       => Builder::ReservedWordBuilder.regexp,
    :comment             => Builder::CommentBuilder.regexp,
    :bracket             => Builder::BracketBuilder.regexp,
    :algebraic_operation => Builder::AlgebraicOperationBuilder.regexp,
    :mystring            => Builder::MystringBuilder.regexp,
    :assignement         => Builder::AssignementBuilder.regexp,
    :punctuation         => Builder::PunctuationBuilder.regexp,
    :boolean_operation   => Builder::BooleanOperationBuilder.regexp,
    :number              => Builder::NumberBuilder.regexp,
    :tordinar            => TYPES[:ordinar].join('|'),
    :treal               => TYPES[:real].join('|'),
    :tboolean            => TYPES[:boolean],
    :tstring             => TYPES[:string],
    :variable            => Builder::VariableBuilder.regexp,
    :undefined           => Builder::UndefinedBuilder.regexp
  }

  ERROR = {
    :input_missing => 'Input string is not given',
    :unknown_token => 'Given token is unknown'
  }

  def initialize string = nil
    @input  = string
    @output = []
  end

  # TODO: remove inner .each_with_index
  def tokenize
    @output.each_with_index do |line, line_number|
      line.each_with_index do |item, index|
        matched_filter = filters.find { |filter| item =~ /#{filter}/ }

        type           = FILTERS.key(matched_filter)
        lexeme         = line[index]

        options = {
          :type   => type,
          :lexeme => lexeme,
          :x      => @lines[line_number].index(line[index]),
          :y      => line_number
        }

        line[index] = Builder.const_get("#{type.to_s.split('_').map {|t| t.capitalize}.join}Builder").build(options)

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
