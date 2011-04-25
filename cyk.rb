require 'set'
require 'ostruct'

require_relative 'cnf_table'
require_relative 'errors'

class Cyk
  include Errors::Cyk

  attr_accessor :start_symbols
  attr_reader :parse_tree
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize string, table
    # TODO: raise errors if @string isn't of String class (same for Array)

    @table         = table
    @string        = string

    @terminals     = @table.values.flatten.select { |value| !value.is_a?(Array) }
    @nterminals    = @table.keys
    @r             = @table.size

    @productions   = productions_from(@table)
    @start_symbols = start_symbols_from(@table)
    @n             = @string.size
    @matrix        = Array.new(@n) { Array.new(@n) { Array.new(@r) { false } } }

    @parse_tree    = []

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
  end

  def productions_from table
    productions = Set.new

    table.each do |nterminal, prods|
      right_sides = prods.select { |p| p.is_a?(Array) }

      right_sides.each { |p| productions << [nterminal] + p } unless right_sides.empty?
    end

    productions
  end

  def start_symbols_from table
    start_symbols = Set.new

    for rule in table
      start_symbols << rule[0] if rule[1].any? { |item| item.is_a?(Array) }
    end

    start_symbols
  end

  def plain_debug array
    puts array.inspect
  end

  def validate
    @start_symbols.each do |symbol|
      i = @nterminals.index(symbol)
      return true if @matrix[0][@n-1][i]
    end

    false
  end

  def prepare_matrix
    for i in 0..@n-1 do
      basic_productions = @nterminals.select { |key| @table[key].include?(@string[i]) }.map {|key| @nterminals.index(key) }
      basic_productions.each { |p| @matrix[i][0][p] = true }
    end
  end

  def update_parse_tree start, length, a
    range = start..(start+length)
    nodes = @parse_tree.select { |node| range.cover?(node.start) && range.cover?(node.start + node.length) }

    if @parse_tree.empty? || nodes.empty?
      @parse_tree << OpenStruct.new({ :start => start, :length => length, :node => @nterminals[a]})
      return
    end

    indexes = nodes.map { |node| @parse_tree.index(node) }
    node = OpenStruct.new({ :start => start, :length => length, :node => @nterminals[a], :children => nodes})
    @parse_tree[indexes.min..indexes.max] = [node]
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

            if @matrix[y][z][b] and @matrix[y+k][x-k][c]
              @matrix[y][x][a] = true

              update_parse_tree(y, x, a)
            end
          end
        end
      end
    end
  end
end
