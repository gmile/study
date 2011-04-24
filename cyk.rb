require 'set'

require_relative 'cnf_table'
require_relative 'errors'

class Cyk
  include Errors::Cyk

  attr_reader :start_symbols
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize options = {}

    # TODO: raise errors if @string isn't of String class (same for Array)

    @table         = options[:table]
    @string        = options[:string]

    @terminals     = @table.values.flatten.select { |value| !value.is_a?(Array) }
    @nterminals    = @table.keys
    @r             = @table.size

    @productions   = productions_from(@table)
    @start_symbols = start_symbols_from(@productions)
    @n             = @string.size
    @matrix        = Array.new(@n) { Array.new(@n) { Array.new(@r) { false } } }

    validate_input
  end

  def debug_info
    puts \
    "@table         : #{@table.inspect}\n" +
    "@string        : #{@string.inspect}\n" +
    "@terminals     : #{@terminals.inspect}\n" +
    "@nterminals    : #{@nterminals.inspect}\n" +
    "@r             : #{@r.inspect}\n" +
    "@productions   : #{@productions.inspect}\n" +
    "@start_symbols : #{@start_symbols.inspect}\n" +
    "@n             : #{@n.inspect}\n" +
    "@matrix        : #{@matrix.inspect}"
  end

  def valid?
    prepare_matrix
    calculate
    validate
  end

  def complexity
    @n*@n*@r
  end

  def trues
    puts @matrix.flatten.select { |item| item == true }
  end

  def print_matrix matrix
    matrix.each_index do |i|
      puts "\n"
      matrix[i].each_index do |j|
        print matrix[i][0][j] ? '1 ' : '0 '
      end
    end
  end

  private
  def validate_input
    a = @table.values.select { |value| value.any? {|v| v.is_a?(Array)} }.flatten.select {|i| i.is_a?(Symbol) }
    b = @nterminals

    raise UnknownTokensException.new(a-b) unless (a - b).empty?
    raise NoPairProductionsException      if     @productions.empty?
    raise NoStartSymbolsGivenException    if     @start_symbols.empty?
  end

  def productions_from table
    productions = Set.new

    table.each do |nterminal, prods|
      right_sides = prods.select { |p| p.is_a?(Array) }

      right_sides.each { |p| productions << [nterminal] + p } unless right_sides.empty?
    end

    productions
  end

  def start_symbols_from productions
    found = Set.new

    for prod in productions
      found << prod[0] unless productions.any? { |p| p[1..2].include?(prod[0]) }
    end

    found
  end

  def plain_debug array
    puts array.inspect
  end

  def validate
    @start_symbols.each do |symbol|
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
          for prod in @productions
            a = @nterminals.index(prod[0])
            b = @nterminals.index(prod[1])
            c = @nterminals.index(prod[2])

            x, y, z = i-1, j-1, k-1

            @matrix[y][x][a] = true if @matrix[y][z][b] and @matrix[y+k][x-k][c]
          end
        end
      end
    end
  end
end
