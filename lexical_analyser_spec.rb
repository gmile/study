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

  it "should parse strings with real values: x := 2.3 + 4.6" do
    @parser.input = "x := 2.3 + 4.6"
    @parser.divide
    @parser.output.should == ['x', ':=', "2.3", '+', "4.6"]
  end

  it "should parse strings as strings: x := 'Hello' + 'dear' + 'world!'" do
    @parser.input = "x := 'Hello' + 'dear' + 'world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello'", '+', "'dear'", '+', "'world!'"]
  end

  it "string should be valid: x := 'Hello world!'" do
    @parser.input = "x := 'Hello world!'"
    @parser.divide
    @parser.valid?.should be_true
  end

  context 'Tokenization' do
    it "should correctly tokenize: x := 2.3 + 4.6" do
      @parser.input = "x := 2.3 + 4.6"
      @parser.divide
      @parser.tokenize
      @parser.output.map { |token| [token.type, token.value] }.should == [
        ['User data',   'x'  ],
        ['Assignement', ':=' ],
        ['Number',      '2.3'],
        ['Operation',   '+'  ],
        ['Number',      '4.6']
      ]
    end
  end
end
