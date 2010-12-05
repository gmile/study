require 'lexical_analyser'

describe Parser do 
  before :each do
    @parser = Parser.new
  end

  it "should parse: x := 2 + 3" do
    @parser.input = 'x := 2 + 3'
    @parser.divide
    @parser.tokenize
    @parser.output.map { |token| [token.type, token.value] }.should == [
      ['User data',   'x' ],
      ['Assignement', ':='],
      ['Number',      '2' ],
      ['Operation',   '+' ],
      ['Number',      '3' ]
    ]
  end

  it "should parse: var_a := var_b + (5 + 10)/23" do
    @parser.input = 'var_a := var_b + (5 + 10)/23'
    @parser.divide
    @parser.tokenize
    @parser.output.map { |token| [token.type, token.value] }.should == [
      ['User data',   'var_a'],
      ['Assignement', ':='   ],
      ['User data',   'var_b'],
      ['Operation',   '+'    ],
      ['Operation',   '('    ],
      ['Number',      '5'    ],
      ['Operation',   '+'    ],
      ['Number',      '10'   ],
      ['Operation',   ')'    ],
      ['Operation',   '/'    ],
      ['Number',      '23'   ]
    ]
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

  context 'Numbers' do
    it "should parse numbers: 123456789 + 12.3456789" do
      @parser.input = "123456789 + 12.3456789"
      @parser.divide
      @parser.output.should == ['123456789', '+', '12.3456789']
    end

    it "should get rid of trailing zeros: 0.1234567890001" do
      @parser.input = "0.1234567890001"
      @parser.divide
      @parser.output.should == ['0.1234567890001']
    end
  end

  it "should parse strings as strings: x := 'Hello' + dear + 'world!'" do
    @parser.input = "x := 'Hello' + dear + 'world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello'", '+', "dear", '+', "'world!'"]
  end

  it "should parse strings with real values: x := 2.3 - 4.6" do
    @parser.input = "x := 2.3 - 4.6"
    @parser.divide
    @parser.output.should == ['x', ':=', "2.3", '-', "4.6"]
  end

  it "should parse strings as strings: x := 'Hello' + 'dear' + 'world!'" do
    @parser.input = "x := 'Hello' + 'dear' + 'world!'"
    @parser.divide
    @parser.output.should == ['x', ':=', "'Hello'", '+', "'dear'", '+', "'world!'"]
  end

  context 'Validity' do
    it "string should be valid: x := 'Hello world!'" do
      @parser.input = "x := 'Hello world!'"
      @parser.divide
      @parser.valid?.should be_true
    end

    it "should parse strings as strings: 1231231231 + 32.1231231213" do
      @parser.input = "1231231231 + .1231231213"
      @parser.divide
      @parser.valid?.should be_false
    end
  end

  context 'Inequalities' do
    it "string should be valid: if a > b then" do
      @parser.input = "if a > b then"
      @parser.divide
      @parser.output.should == ['if', 'a', '>', 'b', 'then']
    end

    it "string should be valid: if a >= b then" do
      @parser.input = "if a >= b then"
      @parser.divide
      @parser.output.should == ['if', 'a', '>=', 'b', 'then']
    end

    it "string should be valid: if a < b then" do
      @parser.input = "if a < b then"
      @parser.divide
      @parser.output.should == ['if', 'a', '<', 'b', 'then']
    end

    it "string should be valid: if a <= b then" do
      @parser.input = "if a <= b then"
      @parser.divide
      @parser.output.should == ['if', 'a', '<=', 'b', 'then']
    end

    it "string should be valid: if a <> b then" do
      @parser.input = "if a <> b then"
      @parser.divide
      @parser.output.should == ['if', 'a', '<>', 'b', 'then']
    end

    it "string should be valid: if (a <> b) and (var = 5) then" do
      @parser.input = "if (a <> b) and (var = 5) then"
      @parser.divide
      @parser.output.should == ['if', '(', 'a', '<>', 'b', ')', 'and', '(', 'var', '=', '5', ')', 'then']
    end

    it "string should be valid: if (a <> b) or (var = 5) then" do
      @parser.input = "if (a <> b) or (var = 5) then"
      @parser.divide
      @parser.output.should == ['if', '(', 'a', '<>', 'b', ')', 'or', '(', 'var', '=', '5', ')', 'then']
    end

    it "string should be valid: if (a <> b) or (var = 5) and (x <= 12.45) or (string = 'lalala') then" do
      @parser.input = "if (a <> b) or (var = 5) and (x <= 12.45) or (string = 'lalala') then"
      @parser.divide
      @parser.output.should == ['if', '(', 'a', '<>', 'b', ')', 'or', '(', 'var', '=', '5', ')', 'and', '(', 'x', '<=', '12.45', ')', 'or', '(', 'string', '=', "'lalala'", ')', 'then']
    end
  end

  it "should parse inline comments" do
    @parser.input = "{ this is a comment line }"
    @parser.divide
    @parser.output.should == ['{ this is a comment line }']
  end

  context 'Tokenization' do
    it "should correctly tokenize all reserved words" do
      @parser.input = Parser::RESERVED_WORDS.join(' ')
      @parser.divide
      @parser.tokenize

      @parser.output.each do |token|
        token.type.should ==  'Reserved word'
      end
    end

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

    it "should correctly tokenize reserved words: if x = 5 then" do
      @parser.input = "if x = 5 then"
      @parser.divide
      @parser.tokenize
      @parser.output.map { |token| [token.type, token.value] }.should == [
        ['Reserved word', 'if'],
        ['User data', 'x'],
        ['Equality', '='],
        ['Number', '5'  ],
        ['Reserved word', 'then']
      ]
    end
  end

  context 'Coordinates' do
    it 'should correctly set coodinates' do
      @parser.input = <<-eos
      for i := 1 to 20 do
      begin
        s := 10;
      end
      eos

      @parser.divide
      @parser.tokenize

      @parser.output.flatten.map { |token| [token.value, token.x, token.y] }.should == [
        ['for',    0, 0],
        ['i',      3, 0],
        [':=',     5, 0],
        ['1',      8, 0],
        ['to',    10, 0],
        ['20',    13, 0],
        ['do',    16, 0],
        ['begin',  0, 1],
        ['s',      2, 2],
        [':=',     4, 2],
        ['10',     7, 2],
        [';',      9, 2],
        ['end',    0, 3]
      ]
    end
  end

  context 'Multiline' do
    it 'should correctly parse a full multiline program' do
      source_code = <<-eos
        uses crt;

        var
          my_var_1 : integer;
          my_var_2 : real;
          x        : string;

        begin
          clrscr;

          my_var_1 = 12;
          while my_var_1 <> 0 do
            dec(my_var_1);
          end
        end.
      eos

      @parser.input = source_code
      @parser.divide

      @parser.output.flatten.should == [
        'uses', 'crt', ';',
        'var',
        'my_var_1', ':', 'integer', ';',
        'my_var_2', ':', 'real', ';',
        'x', ':', 'string', ';',
        'begin',
        'clrscr', ';',
        'my_var_1', '=', '12', ';',
        'while', 'my_var_1', '<>', '0', 'do',
        'dec', '(', 'my_var_1', ')', ';',
        'end',
        'end.'
      ]
    end
  end
end
