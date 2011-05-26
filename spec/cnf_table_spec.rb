require_relative '../cnf_table'
require_relative '../cyk'
require 'rspec/expectations'

RSpec::Matchers.define :be_folded do
  match do |example|
    input_string     = Parser.new(example.description).output.map { |token| token.type }
    expected_folding = example.example_group.description.to_sym
    @cyk             = Cyk.new(input_string, table)

    @cyk.perform_check.should be_true
    @cyk.root.node.nterm == expected_folding
  end

  failure_message_for_should do |example|
    message = "#{example.example_group.description.to_sym} expected, but "
    message << (@cyk.root ? "#{@cyk.root.node} found" : "it was unable to build tree")
  end
end

describe Cyk do
  let!(:table) { CNFTable.table }

  context 'program' do
    it('program test; const x = 5; var y : integer; begin y := x end.') { example.should be_folded }
    it('program test; begin y := x end.')                               { example.should be_folded }
    it('begin y := x end.')                                             { example.should be_folded }
    it('const x = 5; var y : integer; begin y := x end.')               { example.should be_folded }
    it('var y : integer; begin y := x end.')                            { example.should be_folded }

    it('const y = 3; var x : real; function x(a,b:integer) : integer; begin x := 3 end; begin x := 3 end.') { example.should be_folded }
    it('const y = 3; function x(a,b:integer) : integer; begin x := 3 end; begin x := 3 end.')               { example.should be_folded }
    it('var x : integer; function x(a,b:integer) : integer; begin x := 3 end; begin x := 3 end.')           { example.should be_folded }
    it('function x(a,b:integer) : integer; begin x := 3 end; begin x := 3 end.')                            { example.should be_folded }
  end

  context 'program_title_block' do
    it('program foo;')                              { example.should be_folded }
  end

  context 'uses_block' do
    it('uses fuu;')                                 { example.should be_folded }
    it('uses fuu, bar;')                            { example.should be_folded }
    it('uses fuu, bar, baz;')                       { example.should be_folded }
  end

  context 'func_proc' do
    it('procedure test( x: integer; y: string ); begin x := y end') { example.should be_folded }
    it('procedure test( x: integer ); begin x := 3 end')            { example.should be_folded }

    it('function test( x: integer; y: string ) : integer; begin x := y end') { example.should be_folded }
    it('function test( x: integer ) : real; begin x := 3 end')               { example.should be_folded }
  end

  context 'var_with_type' do
    it('a : integer')                               { example.should be_folded }
    it('b : longint')                               { example.should be_folded }
    it('c : byte')                                  { example.should be_folded }
    it('d : word')                                  { example.should be_folded }
    it('e : real')                                  { example.should be_folded }
    it('f : boolean')                               { example.should be_folded }
    it('g : string')                                { example.should be_folded }
    it('A : array[1..cnst] of string')              { example.should be_folded }
    it('a, b, c : integer')                         { example.should be_folded }
  end

  context 'var_with_type_list' do
    it('a : string; x : integer')                   { example.should be_folded }
    it('a, b, c : string; x , y : integer')         { example.should be_folded }
    it('A : array[1..10] of integer; x, y : string') { example.should be_folded }
  end

  context 'var_block' do
    it('var x, y: array[1..10] of real;')           { example.should be_folded }
    it('var x, y, z: real; a, b: integer;')         { example.should be_folded }
  end

  context 'const_block' do
    it('const x = 5;')                              { example.should be_folded }
    it('const x = 5; y = 2;')                       { example.should be_folded }
    it('const x, y = 5;')                           { example.should be_folded }
    it('const x, y = 5; z = 3;')                    { example.should be_folded }
  end

  context 'value_fold' do
    it('x + 1.2')                                   { example.should be_folded }
    it('x + 1.2 + 73')                              { example.should be_folded }
    it('x + 1.2 + 73 + y')                          { example.should be_folded }
    it('x + 1.2 + A[13] + y')                       { example.should be_folded }
    it('x + my_func(5, var_1)')
  end

  context 'value' do
    it('my_array[i+10]')                            { example.should be_folded }
  end

  context 'subs_value' do
    it('[12]')                                      { example.should be_folded }
    it('[12+x]')                                    { example.should be_folded }
  end

  context 'parameters' do
    it('(a)')
    it('(12)')
    it('(12+3, a)')
    it('(a, b, c)')
    it('(12+a+3, a)')
    it("(a, b, 'string')")
  end

  context 'statement_list' do
    it('x := y; x := y;')                           { example.should be_folded }
    it('x := y; a := b; c := d; i := j;')           { example.should be_folded }
  end

  context 'statement' do
    it('begin x := y + z + 5 end')                  { example.should be_folded }
    it('begin x := y + z + 5; end')                 { example.should be_folded }
    it('begin x := y + z + 5; x := 1; y := 4; end') { example.should be_folded }

    it('x := y')                                    { example.should be_folded }
    it('x := y + z')                                { example.should be_folded }
    it('x := y + z + 5')                            { example.should be_folded }
    it 'x := y - 3 * (1 - 2)'
    it 'some_bool := 3 < 5;'

    it('for x := 1 to 10 do x := x - 1')            { example.should be_folded }
    it('for x := 1 downto 10 do y := x - 1')        { example.should be_folded }

    it('if x = 5 then x := 3')                      { example.should be_folded }
    it('if x = 5 then x := 3 else x := 5')          { example.should be_folded }

    it('if x = 5 then begin x := 3 end')                     { example.should be_folded }
    it('if x = 5 then begin x := 3; y := 4 end else x := 1') { example.should be_folded }
    it('if true or false then x := 3')              { example.should be_folded }
    it('if true then x := 3')
    it('if (x or y) then x := 3')

    it('while x < 5 do x := x + 1')                 { example.should be_folded }
    it('while x < 5 do begin x := x + 1 end')       { example.should be_folded }

    it('repeat x := x + 1; until x = 10')           { example.should be_folded }
    it('repeat x := x + 1 until true')              { example.should be_folded }
  end

  context 'Boolean expressions' do
    context 'basic_boolean_expression' do
      it('x = 5')                                   { example.should be_folded }
      it 'expression > expression'
    end

    context 'basic_boolean_expression_n' do
      it('not x = 5')                               { example.should be_folded }
      it('not (x = 5)')
    end

    context 'basic_boolean_expression_w' do
      it('(y)')                                     { example.should be_folded }
      it('(not y)')                                 { example.should be_folded }
    end

    context 'combined_boolean_expression' do
      it('x = 5 and y = 10')                        { example.should be_folded }
      it('x = 5 or y = false')                      { example.should be_folded }
      it('x = 5 and y')                             { example.should be_folded }
      it('x = 5 or y')                              { example.should be_folded }
      it('(x = 5) and (y = true)')                  { example.should be_folded }
      it('(x = 5) and (y = true) or (x = true)')    { example.should be_folded }
      it('(x = 5) or y')                            { example.should be_folded }
      it('(x) or (y)')                              { example.should be_folded }
      it('x and y')                                 { example.should be_folded }
      it('true or false')                           { example.should be_folded }
      it('x = 5 and not y')                         { example.should be_folded }

      it '5 + 10 > 4 - 7'
      it '(combined)'
      it 'not (combined)'
      it '(((((())))))'
    end

    context 'basic_boolean_expression_n' do
      it('not x = 5')                               { example.should be_folded }
    end
  end
end
