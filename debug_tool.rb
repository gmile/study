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
    :functions => [],
    :used      => []
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

  function my_func(a,b,c : integer) : integer;
  begin
    my_func := 5;
    func := 5 + xx;
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

@some_array = some_array = [template]

root = x.roots.first
root.set_block 0, nil, some_array

GUI.show_tree(x.roots)

x = root.extract.each do |item|
  some_array[item.options[:current_block]][:block_info][:parent] =  item.options[:parent_block]
  some_array[item.options[:current_block]][:block_info][:self]   =  item.options[:current_block]
  some_array[item.options[:current_block]][:constants]           << item if item.name == :const_name
  some_array[item.options[:current_block]][:variables]           << item if item.name == :var_name
  some_array[item.options[:current_block]][:functions]           << item if item.name == :func_name
  some_array[item.options[:current_block]][:procedures]          << item if item.name == :proc_name
  some_array[item.options[:current_block]][:used]                << item if [:value,:n_variable].include?(item.name) && item.token.type == :variable
end

some_array.first[:block_info][:lines] = root.options[:lines]

def pretty_print blocks
  blocks.each_with_index do |block, index|
    puts "Block #{index} [#{block[:block_info][:lines][:first]} - #{block[:block_info][:lines][:last]}]"
    puts " - parent: #{block[:block_info][:parent]}"
    puts " - constants: #{block[:constants].map { |x| x.token.lexeme }.join(', ')}"
    puts " - variables: #{block[:variables].map { |x| x.token.lexeme }.join(', ')}"
    puts " - functions: #{block[:functions].map { |x| x.token.lexeme }.join(', ')}"
    puts " - used: #{block[:used].map { |x| x.token.lexeme }.join(', ')}"

    block[:used].each do |nterm|
      puts "ERROR: #{nterm.token.lexeme} if undefined" unless lookup_by_bnt(block[:block_info][:self], nterm.token.lexeme)
    end
    puts
  end
end

def declared_in block
  (block[:constants] + block[:variables] + block[:functions]).map { |x| x.token.lexeme }
end

def lookup_by_block block_number, var_name
  unless block_number.nil?
    block = @some_array[block_number]
   (block[:constants] + block[:variables] + block[:functions]).map { |x| x.token.lexeme }.include?(var_name)
  else
    false
  end
end

def lookup_by_bn block_number, var_name
  if lookup_by_block(block_number, var_name) || lookup_by_block(@some_array[block_number][:block_info][:parent], var_name)
    "'#{var_name}' name declared in #{block_number}"
  else
    'never declared'
  end
end

def lookup_by_bnt block_number, var_name
  if lookup_by_block(block_number, var_name) || lookup_by_block(@some_array[block_number][:block_info][:parent], var_name)
    true
  else
    false
  end
end

puts lookup_by_bn(0, 'i')

pretty_print some_array
