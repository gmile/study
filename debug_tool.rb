require_relative 'cyk'
require_relative 'cnf_table'
require_relative 'lexical_analyser'
require_relative 'console_gui'
require_relative 'table_builder'

def template
  {
    :block_info => {
      :parent => nil,
      :self   => nil,
      :lines  => {
        :first => nil,
        :last  => nil
      }
    },
    :constants => [],
    :variables => [],
    :functions => []
  }
end

string = <<PASCAL
  program test;

  const
    n = 10;
    m = 15;

  var
    i, j : integer;
    a : array[1..10] of real;
    x : real;
    s : string;

  function my_func(a : integer) : integer;
  begin
    my_func := 5;
  end;

  begin
    for i := 1 to 10 do
    begin
      x := 3
    end
  end.
PASCAL

x = Cyk.new(Parser.new(string).output, CNFTable.table)
x.perform_check

some_array = [[]]

root = x.roots.first
root.set_block 0, nil, some_array

GUI.show_tree(x.roots)

root.extract.each do |item|
  some_array[item.options[:current_block]] << item
end

some_array.map! do |item|
  {
    :block_info => {
      :parent => item.first.options[:parent_block],
      :self => item.first.options[:current_block],
      :lines => nil
    },
    :constants => item.select { |x| x.name == :const_name },
    :variables => item.select { |x| x.name == :var_name   },
    :functions => item.select { |x| x.name == :func_name  }
  }
end

def pretty_print blocks
  blocks.each_with_index do |block, index|
    puts "Block #{index}"
    puts " - parent: #{block[:block_info][:parent]}"
    puts " - constants: #{block[:constants].map { |x| x.token.lexeme }.join(', ')}"
    puts " - variables: #{block[:variables].map { |x| x.token.lexeme }.join(', ')}"
    puts " - functions: #{block[:functions].map { |x| x.token.lexeme }.join(', ')}"
    puts
  end
end

pretty_print some_array
