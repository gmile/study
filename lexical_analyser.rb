require 'tokens'

class Parser
  include Tokens

  attr_writer :input
  attr_reader :output

  RESERVED_WORDS = [
    'absolute',    'and',            'array',
    'asm',         'begin',          'case',
    'constructor', 'const',          'destructor',
    'div',         'downto',         'do',
    'else',        'end'             'file',
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
    :comments     => [1,  '\{*.*\}'],
    :bracket      => [2,  '[()]'],
    :operation    => [3,  '[/+\-*]'],
    :strings      => [4,  "\'.*?\'"],
    :assignement  => [5,  ':='],
    :semi         => [6,  '[;:]'],
    :qualities    => [7,  '<>|<=|>=|=|>|<'],
    :number       => [8,  '\d+\.\d+|\d+'],
    :bitter_end   => [9,  'end\.'],          #TODO: refactor me to where I should belong
    :type_ordinar => [10, TYPES[:ordinar].join('|')],
    :type_real    => [11, TYPES[:real].join('|')],
    :type_boolean => [12, TYPES[:boolean]],
    :type_string  => [13, TYPES[:string]],
    :user_data    => [14, '\w+'],
    :undefined    => [15, '[^ \t\r\n\v\f]']
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
          FILTERS.keys.find { |type| FILTERS[type].last == matched_filter } # remove this hack once migrated to ruby 1.9
        end

        value = line[index]

        line[index] = Token.new({
          :type  => type,
          :value => value,
          :x     => @lines[line_number].index(line[index]),
          :y     => line_number
        })

        @lines[line_number][value] = ' '*value.size
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
    unless @input.nil?
      @lines = []
      @input.each_line {|line| @lines << line}

      filter = Regexp.new(filters.join('|'))
      @lines.each do |line|
        @output << line.scan(filter)
      end
    else
      ERROR[:input_missing]
    end
  end

  private

  def filters
    FILTERS.values.sort{|a,b| a.first <=> b.first}.map{|f| f.last }
  end

  def validate
    @undefined = output.find_all { |token| token.undefined? }
  end
end
