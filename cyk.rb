require 'set'
require 'ostruct'

require_relative 'cnf_table'
require_relative 'errors'

class Cyk
  include Errors::Cyk

  attr_reader :start_symbols, :parse_tree
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

  def valid?
    prepare_matrix
    calculate
    validate
  end

  def show_pt branch, depth = 0
    if branch.is_a?(Symbol)
      print ' '*depth + branch.inspect + "\n"
    else
      print ' '*depth + branch.node.to_s + "\n"
      branch.children.each {|c| show_pt c, depth + 2 } unless branch.children.nil?
    end
    nil
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
#    puts '!!!' if start == length+start
    nodes = @parse_tree.select { |node| range.cover?(node.start) && range.cover?(node.start + node.length) }

    if @parse_tree.empty? || nodes.empty?
      @parse_tree << OpenStruct.new({ :start => start, :length => length, :node => @nterminals[a], :children => @string[start..start+length] })
      return
    end

    indexes = nodes.map { |node| @parse_tree.index(node) }
    if nodes.size == 1
      i = start
      if start < nodes.first.start
        i = start
      elsif start + length > nodes.first.start + nodes.first.length - 1
        i = start + length
      end
      nodes << @string[i]
    end

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
