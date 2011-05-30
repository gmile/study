require_relative 'cyk'
require_relative 'cnf_table'
require_relative 'lexical_analyser'
require_relative 'console_gui'
require_relative 'table_builder'

string = ARGV[0]

x = Cyk.new(Parser.new(string).output, CNFTable.table)
x.perform_check

@root = x.roots.first

def find string
  @root.find(string).map { |c| c.find(:n_variable) }.flatten
end

def easy_find string
  @root.find(string).flatten #.map { |c| c.find(:n_variable) }.flatten
end

fc = easy_find :const_name
fv = easy_find :var_name
ff = easy_find :func_name
#ff = easy_find :proc_name

puts ff.size

puts "Block 1: " 
puts "  constants: " + fc.map { |x| x.token.lexeme }.join(', ')
puts "  variables: " + fv.map { |x| x.token.lexeme }.join(', ')
puts "  functions: " + ff.map { |x| x.token.lexeme }.join(', ')


GUI.show_tree(x.roots)
#GUI.show_tree(fc)
#GUI.show_tree(fv)
#GUI.show_tree(ff)

# works
#x = TableBuilder.new(ARGV[0])
#x.try
#puts x.block_array.inspect

#puts x.roots.first.find(:func_ending).inspect

=begin
combined_matrix   = x.combine
max_string_length = combined_matrix.map { |row| row.map { |set| set.to_a.join(', ').size }.max }.max

for row in combined_matrix
  for col in row
    string = col.size.zero? ? '...' : col.to_a.join(', ')
    print string.ljust(max_string_length + 2)
  end
  puts "\n"
end
=end
