@x = 10
y = 20
z = 30

@n_array     = Array.new(@x) { Array.new(y) { nil } }
@plain_array = Array.new(@x*y) { nil }

def get a, b, c
  @n_array[a][b] = 'test'
  @plain_array[a*@x + b] = 'test'

  @n_array[a][b] == @plain_array[a*@x + b]
end

puts get(0,0,0)
