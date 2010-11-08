class Token 
  attr_reader :string
  attr_reader :type

  def initialize string, value
    @string = string
    @value  = value 
  end
end

class Parser
  attr_reader :string
  attr_reader :out

  FILTERS = {
    :user_data   => '\w+',
    :assignement => '\+=',
    :operations  => "[\/+*()]",
    :quotes      => %Q{['"]}
  }

  def initialize string
    @input = string
    @output = []
  end

  def tokenize
    
  end
  
  def divide
    # check for not valid sybols before
    filter = Regexp.new FILTERS.values.join('|')

    @out = @input.scan filter
  end
end

string = %Q{ x_ := 2 mod 0 + (10 + coma/12) * pjotr + "asdsad" + ' + ' }.strip

parser = Parser.new(string)
parser.divide

puts parser.out.inspect
