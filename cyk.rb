require 'set'

require_relative 'cnf_table'
require_relative 'errors'

Node  = Struct.new(:node, :children)
NTerm = Struct.new(:nterm, :index)

class Cyk
  include Errors::Cyk

  attr_reader :start_symbols, :root

  def initialize string, table
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
    validate_input
  end

  def perform_check
    prepare_matrix
    calculate
    validate
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

  def show_tree
    show(@root)
  end

  def show item, depth = 0, symbol = '|'
    unless item.is_a?(Symbol)
      puts "#{' '*4*depth}#{symbol}-- #{item.node.nterm}"

      show(item.children.first, depth+1)
      last = item.children.last
      last.is_a?(Symbol) ? show(last, depth+1, '`') : show(last, depth+1)
    else
      puts "#{' '*4*depth}#{symbol}-- #{item}"
    end
  end

  def complexity
    @n*@n*@r
  end

  private

  def generate_tree root
    root.is_a?(Symbol) ? root : [root.node.nterm, root.children.map { |c| generate_tree c }]
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
      right_sides = prods.select { |p| p.is_a?(Array) }.map do |p|
        a = NTerm.new(p.first, @nterminals.index(p.first))
        b = NTerm.new(p.last, @nterminals.index(p.last))
        [a, b]
      end

      right_sides.each { |p| productions << [NTerm.new(nterminal, @nterminals.index(nterminal))] + p } unless right_sides.empty?
    end

    productions
  end

  def start_symbols_from table
    Set.new(table.select { |_, value| value.any? { |item| item.is_a?(Array) } }.map { |rule, _| rule })
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
        @matrix[i][0][p]     = true
        @parse_tree[i][0][p] = @nterminals[p]
      end
    end
  end

  def calculate
    for i in 2..@n do
      for j in 1..@n-i+1 do
        for k in 1..i-1 do
          for prod in @productions
            a = prod[0].index
            b = prod[1].index
            c = prod[2].index

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
