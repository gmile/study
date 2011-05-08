require_relative '../cnf_table'
require_relative '../cyk'
require 'rspec/expectations'

RSpec::Matchers.define :be_folded do
  match do |example|
    input_string     = Parser.new(example.description).output.map { |token| token.type }
    expected_folding = example.example_group.description.to_sym
    cyk              = Cyk.new(input_string, table)

    cyk.valid?
    @node = cyk.parse_tree.first.node
    @node == expected_folding
  end

  failure_message_for_should do |example|
    "#{example.example_group.description.to_sym} expected, but #{@node} found"
  end
end

describe Cyk do
  let!(:table) { CNFTable.table }

  context 'program_title_fold' do
    it('program foo')                               { example.should be_folded }
  end
  context 'uses_fold' do
    it('uses fuu')                                  { example.should be_folded }
    it('uses fuu, bar')                             { example.should be_folded }
  end

  context 'value_fold' do
    it('x + 1.2 + 73 + y')                          { example.should be_folded }
  end

  context 'common_expr_fold' do
    it('x := y')                                    { example.should be_folded }
    it('x := y + z + 5')                            { example.should be_folded }

    it 'x := y - 3 * (1 - 2)'
    it 'some_bool := 3 < 5;'
  end

  context 'common_expr_fold_list' do
    it('x := y; a := b')                            { example.should be_folded }
    it('x := y; a := b; c := d; i := j')            { example.should be_folded }
  end

  context 'block_fold' do
    it('begin end')                                 { example.should be_folded }
    it('begin x := y + z + 5 end')                  { example.should be_folded }
    it('begin x := y + z + 5; x := 1; y := 4; end') { example.should be_folded }
  end

  context 'boolean_block_fold' do
    context 'basic_boolean_expression' do
      it('x = 5')                                   { example.should be_folded }
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

      it '(combined...)'
      it 'not (combined...)'
      it '(((((())))))'
    end

    context 'basic_boolean_expression_n' do
      it('not x = 5')                               { example.should be_folded }
    end
  end
end
