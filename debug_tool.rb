require_relative 'cyk'
require_relative 'cnf_table'
require_relative 'lexical_analyser'

string = ARGV[0]

x = Cyk.new(Parser.new(string).output.map {|token| token.type }, CNFTable.table)
puts x.valid?
puts x.instance_variable_get(:@r)
puts x.instance_variable_get(:@n)

combined_matrix   = x.combine
max_string_length = combined_matrix.map { |row| row.map { |set| set.to_a.join(', ').size }.max }.max

for row in combined_matrix
  for col in row
    string = col.size.zero? ? '...' : col.to_a.join(', ')
    print string.ljust(max_string_length + 2)
  end
  puts "\n"
end
