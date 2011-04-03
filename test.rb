@dictionary = ['program', 'test', ';']

@table = {
  :r1 => 'program' ,
  :r2 => 'test'    ,
  :r3 => ';'       ,
  :r4 => [:r5, :r3],
  :r5 => [:r1, :r2]
}

@nterminals = @table.keys

n = @dictionary.size
r = @table.size
start_symbols = @table.select { |k,v| v.is_a?(Array) }

matrix = Hash.new

for i in 1..n do
  for j in 1..n do
    for k in 1..r do
      matrix[[i,j,k]] = false
    end
  end
end

for i in 1..n do
  x = @nterminals.index { |key| @table[key] == @dictionary[i-1] } + 1
  matrix[[i,1,x]] = true
end

for i in 2..n do
  for j in 1..n-i+1 do
    for k in 1..i-1 do
      for rule in start_symbols
        a = @nterminals.index { |item| item == rule[0] } + 1
        b = @nterminals.index { |item| item == rule[1].first } + 1
        c = @nterminals.index { |item| item == rule[1].last } + 1

        matrix[[j, i, a]] = true if matrix[[j, k, b]] and matrix[[j+k, i-k, c]]
      end
    end
  end
end

for i in @nterminals.size+1-start_symbols.size..@nterminals.size do
  puts 'success!' if matrix[[1,n,i]]
end

#R1 -> program
#R2 -> test
#R3 -> ok
#R4 -> R5 R3
#R5 -> R1 R2
