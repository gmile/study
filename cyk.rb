require 'set'
require 'progress_bar'

require_relative 'cnf_table'
require_relative 'errors'

Node = Struct.new(:node, :children)

class Cyk
  include Errors::Cyk

  attr_reader :start_symbols, :root
  # @param [Hash] options the options to create a message with.
  # @option options [Array] :string Input string, slplitted into an array
  # @option options [Hash] :table Table of rules
  def initialize string, table, options = {}
    # TODO: raise errors if @string isn't of String class (same for Array)

    @table         = table
    @string        = string

    @nterminals    = @table.keys
    @r             = @table.size

    @productions   = productions_from(@table)
    @start_symbols = start_symbols_from(@table)
    @n             = @string.size

    @matrix        = Array.new(@n) { Array.new(@n) { Array.new(@r) { false } } }
    @parse_tree    = Array.new(@n) { Array.new(@n) { Array.new(@r) { nil   } } }

    @root          = nil
    @progress_bar  = ProgressBar.new(@n-1) if options[:enable_progress]
    validate_input
  end

  def valid?
    prepare_matrix
    calculate
    validate
  end

  def tree
    self.root unless @root

    generate_tree @root
  end

  def combine
    r = Array.new(@n) { Array.new(@n) { Set.new } }
    matrix = @parse_tree

    for m in 0..@r-1
      for row in 0..@n-1
        for col in 0..@n-1
          unless matrix[col][row][m].nil?
            client = matrix[col][row][m]
            r[row][col].merge [client.is_a?(Symbol) ? client : client.node]
          end
        end
      end
    end

    r
  end

  def complexity
    @n*@n*@r
  end

  private

  def generate_tree root
    root.is_a?(Symbol) ? root : [root.node, root.children.map { |c| generate_tree c }]
  end

  def validate_input
    a = @table.values.select { |v| v.any? { |e| e.is_a?(Array)} }.map { |v| v.select { |e| e.is_a?(Array)} }.flatten
    b = @nterminals

    @known_terminals  = @table.values.map { |v| v.select { |e| !e.is_a?(Array)} }.flatten.uniq
    unknown_terminals = (@string - @known_terminals).uniq

    raise UnknownTerminalsException.new unknown_terminals unless unknown_terminals.empty?
    raise UnknownNonTerminalsException.new (a-b).uniq     unless (a - b).empty?
    raise NoPairProductionsException                      if     @productions.empty?
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

      if @matrix[0][@n-1][i]
        @root = @parse_tree[0][@n-1][i]
        return true
      end
    end

    false
  end

  def prepare_matrix
    for i in 0..@n-1 do
      basic_productions = @nterminals.select { |key| @table[key].include?(@string[i]) }.map {|key| @nterminals.index(key) }
      basic_productions.each do |p|
        @matrix[i][0][p] = true
        @parse_tree[i][0][p] = @nterminals[p]
      end
    end
  end

  def calculate
    for i in 2..@n do
      @progress_bar.increment! if @progress_bar

      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for prod in @productions
            a = @nterminals.index(prod[0])
            b = @nterminals.index(prod[1])
            c = @nterminals.index(prod[2])

            x, y, z = i-1, j-1, k-1

            if @matrix[y][z][b] and @matrix[y+k][x-k][c]
              @matrix[y][x][a]     = true
              @parse_tree[y][x][a] = Node.new(prod[0], [@parse_tree[y][z][b], @parse_tree[y+k][x-k][c]])
            end
          end
        end
      end
    end
  end
end
