require_relative 'cyk'
require_relative 'cnf_table'
require_relative 'lexical_analyser'
require_relative 'console_gui'
require_relative 'table_builder'

string = ARGV[0]

x = Cyk.new(Parser.new(string).output, CNFTable.table)
x.perform_check
# works
#x.string_full.each { |x| puts x.inspect }
#GUI.show_tree(x.roots)
#GUI.show_tree(x.roots.find(:constant))
#GUI.show_tree(x.roots.first.find(:constant))
#puts x

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
