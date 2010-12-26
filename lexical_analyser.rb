class Token
  attr_reader :type
  attr_reader :value, :x, :y

  def initialize params
    @type  = params[:type]
    @value = params[:value]
    @x     = params[:x]
    @y     = params[:y]
  end

  def undefined?
    @type == 'Undefined'
  end
end

class Parser
  attr_writer :input
  attr_reader :output
  attr_reader :undefined

  RESERVED_WORDS = [
    'const',    'var',    'uses',
    'begin',    'for',    'do',
    'end',      'not',    'or',
    'and',      'repeat', 'while',
    'true',     'false',  'procedure',
    'function', 'if',     'then',
    'else',     'program'
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
    :user_data   => [8, '\w+'],
    :undefined   => [9, '[^ \t\r\n\v\f]']
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
          when /#{FILTERS[:semi].last}/        then 'Semi'
          when /#{FILTERS[:qualities].last}/   then 'Equality'
          when /#{FILTERS[:numbers].last}/     then 'Number'
          when /#{FILTERS[:bitter_end].last}/  then 'Reserved word'
          when /#{FILTERS[:user_data].last}/   then 'User data'
          when /#{FILTERS[:undefined].last}/   then 'Undefined'
          else ERROR[:unknown_token]
          end
        end

        value = line[index]

        line[index] = Token.new({
          :type  => item,
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

      filter = Regexp.new(FILTERS.values.sort{|a,b| a.first <=> b.first}.map{|f| f.last }.join('|'))
      @lines.each do |line|
        @output << line.scan(filter)
      end
    else
      ERROR[:input_missing]
    end
  end

  private

  def validate
    @undefined = output.find_all { |token| token.undefined? }
  end
end
