class Token
  attr_reader :type
  attr_reader :value

  def initialize string, value
    @type  = string
    @value = value
  end

  def pair
    [@type, @value]
  end
end

class Parser
  attr_writer :input
  attr_reader :output

  RESERVED_WORDS = [
    'const',    'var',    'uses',
    'begin',    'for',    'do',
    'end',      'not',    'or',
    'and',      'repeat', 'while',
    'true',     'false',  'procedure',
    'function', 'if',     'then',
    'else'
  ]

  FILTERS = {
    :operations  => '[/+*()]',
    :strings     => "\'.*?\'",
    :assignement => ':=',
    :numbers     => '\d+[.]?\d+',
    :user_data   => '\w+'
  }

  ERROR = {
    :input_missing => 'Input string is not given',
    :unknown_token => 'Given token is unknown'
  }

  def initialize string = nil
    @input = string
    @output = []
  end

  def tokenize
    # 1. check if reserved word
    # 2. check else
    @output.each do |token|
      item = case token
      when /#{}/  then 'Decimal'
      when /\w+/ then 'Variable'
      end
    end
  end

  def valid?
    unless @input.nil?
      x = @output.map{|i| i.include?("'") ? i.delete(' ') : i}.join
      y = @input.delete(' ')

      x == y
    else
      ERROR[:input_missing]
    end
  end
  
  def divide
    unless @input.nil?
      filter = Regexp.new(FILTERS.values.join('|'))

      @output = @input.scan filter
    else
      ERROR[:input_missing]
    end
  end
end
