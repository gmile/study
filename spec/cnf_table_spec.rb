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
  end
end
