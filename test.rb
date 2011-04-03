class Cyk
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize options = { }
    @dictionary    = options[:dictionary]
    @table         = options[:table]
    @nterminals    = @table.keys
    @r             = @table.size
    @start_symbols = @table.select { |k,v| v.is_a?(Array) }
    @n             = @dictionary.size
  end

  def result
    initialize_matrix
    prepare_matrix
    calculate

    for i in @nterminals.size+1-@start_symbols.size..@nterminals.size do
      return @matrix[[1,@n,i]] ? true : false
    end
  end

  private
  def initialize_matrix
    @matrix = Hash.new

    for i in 1..@n do
      for j in 1..@n do
        for k in 1..@r do
          @matrix[[i,j,k]] = false
        end
      end
    end
  end

  def prepare_matrix
    for i in 1..@n do
      x = @nterminals.index { |key| @table[key] == @dictionary[i-1] } + 1
      @matrix[[i,1,x]] = true
    end
  end

  def calculate
    for i in 2..@n do
      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for rule in @start_symbols
            a = @nterminals.index { |item| item == rule[0]       } + 1
            b = @nterminals.index { |item| item == rule[1].first } + 1
            c = @nterminals.index { |item| item == rule[1].last  } + 1

            @matrix[[j, i, a]] = true if @matrix[[j, k, b]] and @matrix[[j+k, i-k, c]]
          end
        end
      end
    end
  end
end

@string = ['program', 'test', ';']

@table = {
  :r1 => 'program' ,
  :r2 => 'test'    ,
  :r3 => ';'       ,
  :r4 => [:r5, :r3],
  :r5 => [:r1, :r2]
}

puts Cyk.new(:string => @string, :table => @table).valid?

#R1 -> program
#R2 -> test
#R3 -> ok
#R4 -> R5 R3
#R5 -> R1 R2
