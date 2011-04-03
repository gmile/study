#P = [0..n-1, 0..n-1, 0..r-1]

@a = ['program', 'test', ';']

@r = {
  :r1 => 'program' ,
  :r2 => 'test'    ,
  :r3 => ';'       ,
  :r4 => [:r5, :r3],
  :r5 => [:r1, :r2]
}

@r_k = @r.keys

n = @a.size # size of Rules array
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
        #key = rule.keys.first
        #keys = rule.values.first

        a = @r_k.index { |item| item == rule.first } + 1
        b = @r_k.index { |item| item == rule.last.first } + 1
        c = @r_k.index { |item| item == rule.last.last } + 1

        #puts "i = #{i};   j = #{j};   k = #{k}"
        #puts "a = #{a};   b = #{b};   c = #{c}"
        #puts @p[[j, k, b]].inspect + ' '*10 + @p[[j+k, i-k, c]].inspect

        @p[[j, i, a]] = true if @p[[j, k, b]] and @p[[j+k, i-k, c]] 
      end
      #puts ' '*(j-1) + '+'*(i-k) + '-'*k
    end
  end
end

for i in @r_k.size+1-complex_rules.size..@r_k.size do
  puts 'success!' if @p[[1,n,i]]
end

#puts @p.select { |k, v| v == true }.inspect

=begin
  let the input be a string S consisting of n characters: a1 ... an.
  let the grammar contain r nonterminal symbols R1 ... Rr.
  This grammar contains the subset Rs which is the set of start symbols.
  let P[n,n,r] be an array of booleans. Initialize all elements of P to false.
  for each i = 1 to n
    for each unit production Rj -> ai
      set P[i,1,j] = true
  for each i = 2 to n -- Length of span
    for each j = 1 to n-i+1 -- Start of span
      for each k = 1 to i-1 -- Partition of span
        for each production RA -> RB RC
          if P[j,k,B] and P[j+k,i-k,C] then set P[j,i,A] = true
  if any of P[1,n,x] is true (x is iterated over the set s, where s are all the indices for Rs) then
    S is member of language
  else
    S is not member of language
=end


#for i in 2..n do
  #for j in 1..n-i+1 do
    #for k in 1..i-1 do
      ## for each prod cycle
        ## P[j, i, A] = true if P[j, k, b] and P[j+k, i-k, c] 
      ## endfor
      ##puts ' '*(j-1) + '+'*(i-k) + '-'*k
    #end
  #end
#end

#R1 -> program
#R2 -> test
#R3 -> ok
#R4 -> R5 R3
#R5 -> R1 R2
