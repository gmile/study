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
    :operations  => [0, '[/+\-*()]'],
    :strings     => [1, "\'.*?\'"],
    :comments    => [2, '\{.*\}'],
    :assignement => [3, ':='],
    :qualities   => [4, '<>|<=|>=|=|>|<'],
    :numbers     => [6, '\d+\.\d+|\d+'],
    :user_data   => [7, '\w+']
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
      token = if RESERVED_WORDS.include?(token)
        'Reserved word'
      else
        case token
        when /#{FILTERS[:operations].last}/  then 'Operation'
        when /#{FILTERS[:strings].last}/     then 'String'
        when /#{FILTERS[:comments].last}/    then 'Comment'
        when /#{FILTERS[:assignement].last}/ then 'Assignement'
        when /#{FILTERS[:qualities].last}/   then 'Equality'
        when /#{FILTERS[:numbers].last}/     then 'Number'
        when /#{FILTERS[:user_data].last}/   then 'User data'
        else ERROR[:unknown_token]
        end
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
      filter = Regexp.new(FILTERS.values.sort{|a,b| a.first <=> b.first}.map{|f| f.last }.join('|'))
      @output = @input.scan filter
    else
      ERROR[:input_missing]
    end
  end
end
