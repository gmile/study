require 'set'

require_relative 'cnf_table'
require_relative 'errors'
require_relative 'node'

#Node  = Struct.new(:nterm, :children)
NTerm = Struct.new(:name, :index, :token)

class Cyk
  include Errors::Cyk

  attr_reader :start_symbols, :roots, :string_full

  def initialize string, table
    @table         = table

    @string_full = nil
    @string = if string.first.is_a?(String) || string.first.is_a?(Symbol)
      string
    else
      @string_full = string
      string.map { |lexem| lexem.type }
    end

    @nterminals    = @table.keys
    @r             = @table.size

    @productions   = productions_from(@table)
    @start_symbols = start_symbols_from(@table)
    @n             = @string.size

    @matrix        = Array.new(@n) { Array.new(@n) { Array.new(@r) { nil } } }

    @root          = nil
    validate_input
  end

  def perform_check
    prepare_matrix
    calculate
    validate
    set_roots
  end

  private

  def set_roots
    @roots = @matrix[0][@n-1].compact.select { |s| @start_symbols.include?(s.nterm.name) }
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
    @start_symbols.select { |symbol| @matrix[0][@n-1][@nterminals.index(symbol)] }.empty? ? false : true
  end

  def prepare_matrix
    for i in 0..@n-1 do
      basic_productions = @nterminals.select { |key| @table[key].include?(@string[i]) }.map {|key| @nterminals.index(key) }
      basic_productions.each do |p|
        if @string_full.nil?
          @matrix[i][0][p] = NTerm.new(@nterminals[p], p)
        else
          @matrix[i][0][p] = NTerm.new(@nterminals[p], p, @string_full[i])
        end
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
              @matrix[y][x][a] = Node.new(prod[0], [@matrix[y][z][b], @matrix[y+k][x-k][c]])
            end
          end
        end
      end
    end
  end
end
