require_relative '../lexical_analyser'

describe Parser do
  before :each do
    @parser = Parser.new
  end

  it "should parse: x := 2 + 3" do
    @parser.input = 'x := 2 + 3'
    @parser.divide
    @parser.tokenize
    @parser.output.map { |token| [token.type, token.value] }.should == [
      [:user_data,   'x' ],
      [:assignement, ':='],
      [:number,      '2' ],
      [:operation,   '+' ],
      [:number,      '3' ]
    ]
  end

  it "should parse: var_a := var_b + (5 + 10)/23" do
    @parser.input = 'var_a := var_b + (5 + 10)/23'
    @parser.divide
    @parser.tokenize
    @parser.output.map { |token| [token.type, token.value] }.should == [
      [:user_data,   'var_a'],
      [:assignement, ':='   ],
      [:user_data,   'var_b'],
      [:operation,   '+'    ],
      [:bracket,     '('    ],
      [:number,      '5'    ],
      [:operation,   '+'    ],
      [:number,      '10'   ],
      [:bracket,     ')'    ],
      [:operation,   '/'    ],
      [:number,      '23'   ]
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

  it "should parse arrays: x := a[3]" do
    @parser.input = "x := a[3]"
    @parser.divide
    @parser.output.should == ['x', ':=', 'a', '[', '3', ']']
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
      @parser.tokenize
      @parser.valid?.should be_true
    end

    it "should not be valid: 123456 + .789" do
      @parser.input = "123456 + .789"
      @parser.divide
      @parser.tokenize
      @parser.valid?.should be_false
    end

    it "should not be valid: 123456 + 789." do
      @parser.input = "123456 + 789."
      @parser.divide
      @parser.tokenize
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
        token.type.should == :reserved_word
      end
    end

    it "should correctly tokenize: x := 2.3 + 4.6" do
      @parser.input = "x := 2.3 + 4.6"
      @parser.divide
      @parser.tokenize
      @parser.output.map { |token| [token.type, token.value] }.should == [
        [:user_data,   'x'  ],
        [:assignement, ':=' ],
        [:number,      '2.3'],
        [:operation,   '+'  ],
        [:number,      '4.6']
      ]
    end

    it "should correctly tokenize reserved words: if x = 5 then" do
      @parser.input = "if x = 5 then"
      @parser.divide
      @parser.tokenize
      @parser.output.map { |token| [token.type, token.value] }.should == [
        [:reserved_word, 'if'  ],
        [:user_data,     'x'   ],
        [:quality,       '='   ],
        [:number,        '5'   ],
        [:reserved_word, 'then']
      ]
    end

    it "should correctly tokenize reserved words: program test;" do
      @parser.input = "program test;"
      @parser.divide
      @parser.tokenize
      @parser.output.map { |token| [token.type, token.value] }.should == [
        [:reserved_word, 'program'],
        [:user_data,     'test'   ],
        [:colon,         ';'      ],
      ]
    end
  end

  context 'Coordinates' do
    it 'should correctly set coodinates' do
      @parser.input = <<-eos
for i := 1 to 20 do
begin
  s := 10; s := 12; s := 14;
end
eos

      @parser.divide
      @parser.tokenize

      @parser.output.flatten.map { |token| [token.value, token.x, token.y, token.type] }.should == [
        ['for',    0, 0, :reserved_word],
        ['i',      4, 0, :user_data    ],
        [':=',     6, 0, :assignement  ],
        ['1',      9, 0, :number       ],
        ['to',    11, 0, :reserved_word],
        ['20',    14, 0, :number       ],
        ['do',    17, 0, :reserved_word],
        ['begin',  0, 1, :reserved_word],
        ['s',      2, 2, :user_data    ],
        [':=',     4, 2, :assignement  ],
        ['10',     7, 2, :number       ],
        [';',      9, 2, :colon        ],
        ['s',     11, 2, :user_data    ],
        [':=',    13, 2, :assignement  ],
        ['12',    16, 2, :number       ],
        [';',     18, 2, :colon        ],
        ['s',     20, 2, :user_data    ],
        [':=',    22, 2, :assignement  ],
        ['14',    25, 2, :number       ],
        [';',     27, 2, :colon        ],
        ['end',    0, 3, :reserved_word]
      ]
    end
  end

  context 'Multiline' do
    it 'should correctly parse a full multiline program (example 2)' do
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

    it 'should correctly parse a full multiline program (example 1)' do
      source_code = <<-eos
        program test;

        var
          a, b : integer;
          dc : real;

        begin
          a := 15 + 135;

          if a <> 0 then
          begin
            write("a");
            read(a);
          end;
        end.
      eos

      @parser.input = source_code
      @parser.divide

      @parser.output.flatten.should == [
        'program', 'test', ';',
        'var',
        'a', ',', 'b', ':', 'integer', ';',
        'dc', ':', 'real', ';',
        'begin',
        'a', ':=', '15', '+', '135', ';',
        'if', 'a', '<>', '0', 'then',
        'begin',
        'write', '(', '"', 'a', '"', ')', ';',
        'read', '(', 'a', ')', ';',
        'end', ';',
        'end.'
      ]
    end
  end
end
