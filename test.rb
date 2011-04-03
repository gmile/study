@a = ['program', 'test', ';']

@r = {
  :r1 => 'program' ,
  :r2 => 'test'    ,
  :r3 => ';'       ,
  :r4 => [:r5, :r3],
  :r5 => [:r1, :r2]
}

@r_k = @r.keys

n = @a.size
r = @r.size

@p = Hash.new

for i in 1..n do
  for j in 1..n do
    for k in 1..r do
      @p[[i,j,k]] = false
    end
  end
end

for i in 1..n do
  x = @r_k.index { |key| @r[key] == @a[i-1] } + 1
  @p[[i,1,x]] = true
end

complex_rules = @r.select { |k,v| v.is_a?(Array) }

for i in 2..n do
  for j in 1..n-i+1 do
    for k in 1..i-1 do
      for rule in complex_rules
        a = @r_k.index { |item| item == rule[0] } + 1
        b = @r_k.index { |item| item == rule[1].first } + 1
        c = @r_k.index { |item| item == rule[1].last } + 1

        @p[[j, i, a]] = true if @p[[j, k, b]] and @p[[j+k, i-k, c]] 
      end
    end
  end
end

for i in @r_k.size+1-complex_rules.size..@r_k.size do
  puts 'success!' if @p[[1,n,i]]
end

#R1 -> program
#R2 -> test
#R3 -> ok
#R4 -> R5 R3
#R5 -> R1 R2
