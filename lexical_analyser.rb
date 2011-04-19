require_relative 'builder'
require_relative 'errors'

class Parser
  attr_writer :input
  attr_reader :output

  # TODO: add '.' as a reserved word + test for it

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
    :type                => Builder::TypeBuilder.regexp,
    :variable            => Builder::VariableBuilder.regexp,
    :undefined           => Builder::UndefinedBuilder.regexp
  }

  def initialize string = nil
    @input  = string
    @output = []
  end

  def valid?
    @output.any? { |token| token.is_a?(Tokens::Undefined) }
  end

  def output
    raise Errors::InputMissingException if @input.nil? || @input.empty?

    divide
    tokenize
    @output.flatten
  end

  private

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

        line[index] = Builder.const_get(builder_name_from(type)).build(options)

        @lines[line_number][lexeme] = ' '*lexeme.size
      end
    end
  end

  def builder_name_from type
    "#{type.to_s.split('_').map {|t| t.capitalize}.join}Builder"
  end

  def divide
    @lines = []
    @input.each_line {|line| @lines << line }

    filter = Regexp.new(filters.join('|'))
    @output = @lines.map { |line| line.scan(filter) }
  end

  def filters
    FILTERS.values
  end
end
