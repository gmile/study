class Token
  attr_reader :type
  attr_reader :value

  def initialize type, value
    @type  = type
    @value = value
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
    @output.each_with_index do |token, index|
      token = case token
      when RESERVED_WORDS.any? { |word| token == word } then 'Reserved word'
      when /#{FILTERS[:numbers]}/     then 'Number'
      when /#{FILTERS[:operations]}/  then 'Operation'
      when /#{FILTERS[:user_data]}/   then 'User data'
      when /#{FILTERS[:strings]}/     then 'String'
      when /#{FILTERS[:assignement]}/ then 'Assignement'
      else ERROR[:unknown_token]
      end

      @output[index] = Token.new(token, @output[index])
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
