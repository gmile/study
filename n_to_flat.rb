@x = 10

class MyArray < Array
  def initialize n, size
    @size = size
    super(n)
  end

  def [](a, b, c)
    super (a*@size + b)*c
  end

  def []=(a, b, c, value)
    super (a*@size + b)*c, value
  end
end

@n_array     = Array.new(@x) { Array.new(y) { Array.new(z) { nil } } }
@plain_array = MyArray.new(@x*y*z, @x) { nil }

@plain_array[1,2,3] = 'value'
puts @plain_array[1,2,3]
