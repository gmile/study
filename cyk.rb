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
    @matrix        = Array.new(@n) { Array.new(@n) { Array.new(@r) { false } } }
  end

  def valid?
    # TODO: consider using the following approach:
    # .define_singletone_method on matrix so it will look like:
    #  - matrix.initialize
    #  - matrix.prepare
    #  - matrix.calculate
    #

    prepare_matrix
    calculate
    validate
  end

  private

  def validate
    @start_symbols.keys.each do |symbol|
      i = @nterminals.index(symbol)
      return @matrix[0][@n-1][i] ? true : false
    end
  end

  def prepare_matrix
    for i in 0..@n-1 do
      x = @nterminals.index { |key| @table[key] == @string[i] }
      @matrix[i][0][x] = true
    end
  end

  def calculate
    for i in 2..@n do
      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for rule in @start_symbols
            a = @nterminals.index(rule[0])
            b = @nterminals.index(rule[1].first)
            c = @nterminals.index(rule[1].last)

            x, y, z = i-1, j-1, k-1

            @matrix[y][x][a] = true if @matrix[y][z][b] and @matrix[y+k][x-k][c]
          end
        end
      end
    end
  end
end
