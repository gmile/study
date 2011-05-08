require_relative '../cnf_table'
require_relative '../cyk'

describe Cyk do
  let!(:table) { CNFTable.table }

  def test_folding string, expected_folding
    cyk = Cyk.new(string, table)

    cyk.valid?.should be_true
    cyk.parse_tree.first.node.should == expected_folding
  end

  it 'program_title_fold' do
    test_folding [:program, :variable], :program_title_fold
  end

  context 'uses_fold' do
    it 'with only one arg' do
      test_folding [:uses, :variable], :uses_fold
    end

    it 'with several args' do
      test_folding [:uses, :variable, :coma, :variable], :uses_fold
    end
  end

  it 'value fold' do
    test_folding [:variable, :add, :real, :add, :integer, :add, :variable], :value_fold
  end

  context 'common_expr_fold' do
    it 'simple right side' do
      test_folding [:variable, :assignement, :variable], :common_expr_fold
    end

    it 'complex right side' do
      test_folding [:variable, :assignement, :variable, :add, :variable, :add, :integer], :common_expr_fold
    end
  end

  context 'common_expr_fold_list' do
    it 'simple right side' do
      test_folding [:variable, :assignement, :variable, :semicolon, :variable, :assignement, :variable], :common_expr_fold_list
    end

    it 'complex right side' do
      string = [
        :variable, :assignement, :variable, :semicolon,
        :variable, :assignement, :variable, :semicolon,
        :variable, :assignement, :variable, :semicolon,
        :variable, :assignement, :variable
      ]

      test_folding string, :common_expr_fold_list
    end
  end

  context 'block_fold' do
    it 'with no statements' do
      test_folding [:begin, :end], :block_fold
    end

    it 'with one statement' do
      test_folding [:begin, :variable, :assignement, :variable, :add, :variable, :add, :integer, :end], :block_fold
    end

    it 'with multiple statement' do
      test_folding [
        :begin,
        :variable, :assignement, :variable, :add, :variable, :add, :integer, :semicolon,
        :variable, :assignement, :integer, :semicolon,
        :variable, :assignement, :integer, :end
      ], :block_fold
    end
  end

  context 'boolean_block_fold' do
    context 'boolean_block_body' do
      it 'x = 5' do
        test_folding [:variable, :equal, :integer], :basic_boolean_expression
      end

      it 'x = 5 and y = 10' do
        test_folding [:variable, :equal, :integer, :and, :variable, :equal, :integer], :combined_boolean_expression
      end

      it 'x = 5 or y = false' do
        test_folding [:variable, :equal, :integer, :and, :variable, :equal, :false], :combined_boolean_expression
      end

      it 'x = 5 and y' do
        test_folding [:variable, :equal, :integer, :and, :false], :combined_boolean_expression
      end

      it 'x = 5 or y' do
        test_folding [:variable, :equal, :integer, :or, :variable], :combined_boolean_expression
      end

      it '(x = 5) and (y = true)' do
        test_folding [
          :left_bracket, :variable, :equal, :integer, :right_bracket,
          :and,
          :left_bracket, :variable, :equal, :true, :right_bracket], :combined_boolean_expression
      end

      it '(x = 5) and (y = true) or (x = true)' do
        test_folding [
          :left_bracket, :variable, :equal, :integer, :right_bracket,
          :and,
          :left_bracket, :variable, :equal, :true, :right_bracket,
          :or,
          :left_bracket, :variable, :equal, :true, :right_bracket], :combined_boolean_expression
      end

      it '(x = 5) or y' do
        test_folding [
          :left_bracket, :variable, :equal, :integer, :right_bracket,
          :or,
          :variable], :combined_boolean_expression
      end

      it '(x) or (y)' do
        test_folding [:left_bracket, :variable, :right_bracket, :and, :left_bracket, :variable, :right_bracket], :combined_boolean_expression
      end

      it 'x and y' do
        test_folding [:variable, :and, :variable], :combined_boolean_expression
      end

      it 'true or false' do
        test_folding [:true, :or, :false], :combined_boolean_expression
      end

      it 'x = 5 and not y' do
        test_folding [:variable, :equal, :integer, :and, :not, :variable], :combined_boolean_expression
      end

      it '(combined...)'
      it 'not (combined...)'
      it '(((((())))))' # we can have any depth...

      it 'not x = 5' do
        test_folding [:not, :variable, :equal, :integer], :basic_boolean_expression_n
      end
    end
  end
end
