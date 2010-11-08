class Parser
  attr_accessor :rules

  def initialize hash
    @rules = hash
  end

  def parse string
    s = string.delete(' ')

    
  end
end

# X - number | variable | constant
# Y - left-side variable ?
# A - assignement
# R - result
# O - operation

rules = {
  'R -> X A',
  'R -> R X',
  'R -> O X',
  'R -> R O'
}

sentance = 'y := 2 * 3 - 4 / var'

x = Parser.new rules 
#X -> X Z
#Z -> OP X
#G -> PR X
#R -> X G
#
#PR -> EQ

#X -> a
#X -> b
#X -> c

#OP -> ADD
#OP -> SUB
#OP -> MUL
#OP -> DIV
