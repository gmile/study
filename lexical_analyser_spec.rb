require 'lexical_analyser'

describe Parser do 
  before :each do
    @parser = Parser.new
  end

  it "should parse: x := 2 + 3" do
    @parser.input = 'x := 2 + 3'
    @parser.divide
    @parser.output.should == ['x', ':=', '2', '+', '3']
  end

  it "should parse: var_a := var_b + (5 + 10)/23" do
    @parser.input = 'var_a := var_b + (5 + 10)/23'
    @parser.divide
    @parser.output.should == ['var_a', ':=', 'var_b', '+', '(', '5', '+', '10', ')', '/', '23']
  end

  it "should parse: x_ := 2 mod 0 + (10 + coma/12) * pjotr + 'asdsad'" do
    @parser.input = "x_ := 2 mod 0 + (10 + coma/12) * pjotr + 'asdsad'"
    @parser.divide
    @parser.output.should == ['x_', ':=', '2', 'mod', '0', '+', '(', '10', '+', 'coma', '/', '12', ')', '*', 'pjotr', '+', "'asdsad'"]
  end

  it "should return an error if no input string given" do
    @parser.divide.should == Parser::ERROR[:input_missing]
  end
  
  it "should parse strings as strings: x := 'Hello world!'" do
    @parser.input = "x := 'Hello world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello world!'"]
  end
  
  it "should parse strings as strings: x := 'Hello' + dear + 'world!'" do
    @parser.input = "x := 'Hello' + dear + 'world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello'", '+', "dear", '+', "'world!'"]
  end

  it "should parse strings as strings: x := 'Hello' + dear + 'world!'" do
    @parser.input = "x := 'Hello' + 'dear' + 'world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello'", '+', "'dear'", '+', "'world!'"]
  end

  it "string should be valid: x := 'Hello world!'" do
    @parser.input = "x := 'Hello world!'"
    @parser.divide
    @parser.valid?.should be_true
  end
end
