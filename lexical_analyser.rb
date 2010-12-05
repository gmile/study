class Token
  attr_reader :type
  attr_reader :value, :x, :y

  def initialize params
    @type  = params[:type]
    @value = params[:value]
    @x     = params[:x]
    @y     = params[:y]
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

  def output
    @output.size > 1 ? @output : @output.flatten
  end

  FILTERS = {
    :operations  => [0, '[/+\-*()]'],
    :strings     => [1, "\'.*?\'"],
    :comments    => [2, '\{.*\}'],
    :assignement => [3, ':='],
    :semi        => [4, '[;:]'],
    :qualities   => [5, '<>|<=|>=|=|>|<'],
    :numbers     => [6, '\d+\.\d+|\d+'],
    :bitter_end  => [7, 'end\.'],          #TODO: refactor me to where I should belong
    :user_data   => [8, '\w+']
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
        item = if RESERVED_WORDS.include?(item)
          'Reserved word'
        else
          case item
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

        line[index] = Token.new({
          :type  => item,
          :value => line[index],
          :x     => index,
          :y     => line_number
        })
      end
    end
  end

  def valid?
    unless @input.nil?
      x = output.map{|i| i.include?("'") ? i.delete(' ') : i}.join
      y = @input.delete(' ')

      x == y
    else
      ERROR[:input_missing]
    end
  end

  def divide
    unless @input.nil?
      filter = Regexp.new(FILTERS.values.sort{|a,b| a.first <=> b.first}.map{|f| f.last }.join('|'))
      @input.each_line do |line|
        @output << line.scan(filter)
      end
    else
      ERROR[:input_missing]
    end
  end
end
