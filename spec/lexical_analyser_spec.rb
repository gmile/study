require_relative '../lexical_analyser'
require_relative '../errors'

describe Parser do
  before :each do
    @parser = Parser.new
  end

  it "should parse: x := 2 + 3" do
    @parser.input = 'x := 2 + 3'
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,    'x' ],
      [:assignement, ':='],
      [:integer,     '2' ],
      [:add,         '+' ],
      [:integer,     '3' ]
    ]
  end

  it "should parse strings with real values: x := 2.3 - 4.5" do
    @parser.input = "x := 2.3 - 4.5"
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,    'x'  ],
      [:assignement, ':=' ],
      [:real,        '2.3'],
      [:sub,         '-'  ],
      [:real,        '4.5']
    ]
  end

  it "should parse: () as :bracket_left and :bracket_right" do
    @parser.input = '()[]'
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:left_bracket,     '('],
      [:right_bracket,    ')'],
      [:sq_left_bracket,  '['],
      [:sq_right_bracket, ']']
    ]
  end

  it "should parse: var_a := var_b + (5 + 10)/23" do
    @parser.input = 'var_a := var_b + (5 + 10)/23'
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,      'var_a'],
      [:assignement,   ':='   ],
      [:variable,      'var_b'],
      [:add,           '+'    ],
      [:left_bracket,  '('    ],
      [:integer,       '5'    ],
      [:add,           '+'    ],
      [:integer,       '10'   ],
      [:right_bracket, ')'    ],
      [:div,           '/'    ],
      [:integer,       '23'   ]
    ]
  end

  it "should parse: x_ := 2 mod 0 + (10 + coma/12) * pjotr + 'asdsad'" do
    @parser.input = "x_ := 2 mod 0 + (10 + coma/12) * pjotr + 'asdsad'"
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,      'x_'      ],
      [:assignement,   ':='      ],
      [:integer,       '2'       ],
      [:mod,           'mod'     ],
      [:integer,       '0'       ],
      [:add,           '+'       ],
      [:left_bracket,  '('       ],
      [:integer,       '10'      ],
      [:add,           '+'       ],
      [:variable,      'coma'    ],
      [:div,           '/'       ],
      [:integer,       '12'      ],
      [:right_bracket, ')'       ],
      [:mul,           '*'       ],
      [:variable,      'pjotr'   ],
      [:add,           '+'       ],
      [:string,        "'asdsad'"]
    ]
  end

  it "should return an error if no input string given" do
    lambda { @parser.output }.should raise_error(Errors::InputMissingException, 'Input string is not given.')
  end

  it "should parse arrays: x := a[3]" do
    @parser.input = "x := a[3]"
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,         'x' ],
      [:assignement,      ':='],
      [:variable,         'a' ],
      [:sq_left_bracket,  '[' ],
      [:integer,          '3' ],
      [:sq_right_bracket, ']' ]
    ]
  end

  context 'Numbers' do
    it "should parse numbers: 123456789 + 12.3456789" do
      @parser.input = "123456789 + 12.3456789"
      @parser.output.map { |token| [token.type, token.lexeme] }.should == [
        [:integer, '123456789' ],
        [:add,     '+'         ],
        [:real,    '12.3456789']
      ]
    end

    it "should get rid of trailing zeros: 0.1234567890001" do
      @parser.input = "0.1234567890001"
      @parser.output.map { |token| [token.type, token.lexeme] }.should == [
        [:real, '0.1234567890001']
      ]
    end
  end

  it "should parse inline comments" do
    @parser.input = "a := 2 { this is a comment line }"
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:variable,    'a' ],
      [:assignement, ':='],
      [:integer,     '2' ],
      [:comment,     '{ this is a comment line }' ]
    ]
  end

  context 'Validity' do
    it "should not be valid: 123456 + 1.789" do
      @parser.input = "123456 + 1.789"
      puts @parser.output.map { |token| token.lexeme }.should == ['123456', '+', '1.789']

      @parser.valid?.should be_true
    end

    it "should not be valid: 123456 + # 789" do
      @parser.input = "123456 + # 789"
      @parser.output.map { |token| token.lexeme }.should == ['123456', '+', '#', '789']

      @parser.valid?.should be_false
    end
  end

  it "should correctly tokenize reserved words: program test;" do
    @parser.input = "program test;"
    @parser.output.map { |token| [token.type, token.lexeme] }.should == [
      [:program,   'program'],
      [:variable,  'test'   ],
      [:semicolon, ';'      ]
    ]
  end

  context 'Inequalities' do
    it "should parse: >" do
      @parser.input = "<> <= >= = > <"
      @parser.output.map { |token| [token.type, token.lexeme] }.should == [
        [:not_equal,        '<>'],
        [:less_or_equal,    '<='],
        [:greater_or_equal, '>='],
        [:equal,            '=' ],
        [:greater_then,     '>' ],
        [:less_then,        '<' ]
      ]
    end

    it "string should be valid: if (a <> b) or true or false and (5 < 4) then" do
      @parser.input = "if (a <> b) and (var = 5) then"
      @parser.output.should == ['if', '(', 'a', '<>', 'b', ')', 'and', '(', 'var', '=', '5', ')', 'then']
    end

    it "should correctly tokenize reserved words: if x = 5 then" do
      @parser.input = "if x = 5 then"
      @parser.output.map { |token| [token.type, token.lexeme] }.should == [
        [:if,       'if'  ],
        [:variable, 'x'   ],
        [:equal,    '='   ],
        [:integer,  '5'   ],
        [:then,     'then']
      ]
    end
  end

  context 'Tokenization' do
  end

  context 'Coordinates' do
    it 'should correctly set coodinates' do
      @parser.input = <<-eos
for i := 1 to 20 do
begin
  s := 10; s := 12; s := 14;
end
eos

      @parser.output.flatten.map { |token| [token.type, token.lexeme, token.x, token.y] }.should == [
        [:for,           'for',    0, 0],
        [:variable,      'i',      4, 0],
        [:assignement,   ':=',     6, 0],
        [:integer,       '1',      9, 0],
        [:to,            'to',    11, 0],
        [:integer,       '20',    14, 0],
        [:do,            'do',    17, 0],
        [:begin,         'begin',  0, 1],
        [:variable,      's',      2, 2],
        [:assignement,   ':=',     4, 2],
        [:integer,       '10',     7, 2],
        [:semicolon,     ';',      9, 2],
        [:variable,      's',     11, 2],
        [:assignement,   ':=',    13, 2],
        [:integer,       '12',    16, 2],
        [:semicolon,     ';',     18, 2],
        [:variable,      's',     20, 2],
        [:assignement,   ':=',    22, 2],
        [:integer,       '14',    25, 2],
        [:semicolon,     ';',     27, 2],
        [:end,           'end',    0, 3]
      ]
    end
  end

  context 'Multiline' do
    it 'should correctly parse a full multiline program (example 2)' do
      @parser.input = <<-eos
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

      @parser.output.map { |token| token.lexeme }.should == [
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
        'end', '.'
      ]
    end

    it 'should correctly parse a full multiline program (example 1)' do
      @parser.input = <<-eos
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

      @parser.output.map { |token| token.lexeme }.should == [
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
        'end', '.'
      ]
    end
  end
end
