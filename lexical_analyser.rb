class Token 
  attr_reader :string
  attr_reader :type

  def initialize string, value
    @string = string
    @value  = value 
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
    :numbers     => '\d+[.]?\d+',
    :operations  => '[/+*()]',
    :user_data   => '\w+',
    :strings     => "\'.*?\'",   # /'\w+'/
    :assignement => ':=',
  }

  ERROR = {
    :input_missing => 'Input string is not given'
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
