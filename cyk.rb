class Cyk
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize options = { }
    @string        = options[:string]
    @table         = options[:table]
    @nterminals    = @table.keys
    @r             = @table.size
    @start_symbols = @table.select { |k,v| v.is_a?(Array) }
    @n             = @string.size
  end

  def valid?
    initialize_matrix
    prepare_matrix
    calculate
    validate
  end

  private
  def validate
    @start_symbols.keys.each do |symbol|
      i = @nterminals.index(symbol) + 1
      return @matrix[[1,@n,i]] ? true : false
    end
  end

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
      x = @nterminals.index { |key| @table[key] == @string[i-1] } + 1
      @matrix[[i,1,x]] = true
    end
  end

  def calculate
    for i in 2..@n do
      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for rule in @start_symbols
            a = @nterminals.index(rule[0])       + 1
            b = @nterminals.index(rule[1].first) + 1
            c = @nterminals.index(rule[1].last)  + 1

            @matrix[[j, i, a]] = true if @matrix[[j, k, b]] and @matrix[[j+k, i-k, c]]
          end
        end
      end
    end
  end
end
