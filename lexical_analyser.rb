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
    :numbers     => [5, '\d+\.\d+|\d+'],
    :user_data   => [6, '\w+'],
    :num_todo    => [7, '[^0*](.*[^0*$])']
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
        when /#{FILTERS[:numbers].last}/     then 'Number'
        when /#{FILTERS[:operations].last}/  then 'Operation'
        when /#{FILTERS[:user_data].last}/   then 'User data'
        when /#{FILTERS[:strings].last}/     then 'String'
        when /#{FILTERS[:assignement].last}/ then 'Assignement'
        when /#{FILTERS[:qualities].last}/   then 'Equality'
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
