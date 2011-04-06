class Cyk
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize options = { }
    @table = options[:table].inject({}) do |table, hash|
      key, value = hash.first, hash.last
      value      = [value] unless value.is_a?(Array) && value.any? { |type| type.is_a? (Array) || type.is_a?(Symbol) }

      table.merge!(Hash[key, value])
    end

    @string        = options[:string]
    @terminals     = @table.values.select { |value| !value.any? { |item| item.is_a?(Array) } }
    @nterminals    = @table.keys
    @r             = @table.size
    @start_symbols = @table.select { |key, value| value.any? { |item| item.is_a?(Array) } }.reject { |key, value| value.any? { |item| item.is_a?(Array) } }
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

  def matrix_debug
    @matrix.each do |row|
      puts row.inspect
    end
  end

  def validate
    @start_symbols.keys.each do |symbol|
      i = @nterminals.index(symbol)
      return @matrix[0][@n-1][i] ? true : false
    end
  end

  def prepare_matrix
    for i in 0..@n-1 do
      x = @nterminals.index { |key| @table[key].include?(@string[i]) }
      @matrix[i][0][x] = true
    end
  end

  def calculate
    for i in 2..@n do
      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for rule in @start_symbols
            for origins in rule[1]
              a = @nterminals.index(rule[0])
              b = @nterminals.index(origins.first)
              c = @nterminals.index(origins.last)

              x, y, z = i-1, j-1, k-1

              @matrix[y][x][a] = true if @matrix[y][z][b] and @matrix[y+k][x-k][c]
            end
          end
        end
      end
    end
  end
end
