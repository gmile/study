require_relative '../cnf_table'
require_relative '../cyk'

describe Cyk do
  let!(:table) { CNFTable.table }

  it 'program_title_fold' do
    string = [:program, :variable]

    cyk = Cyk.new(string, table)

    cyk.valid?.should be_true
    cyk.parse_tree.last.last.should == :program_title_fold
  end

  context 'uses_fold' do
    it 'with only one arg' do
      string = [:uses, :variable]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :uses_fold
    end

    it 'with several args' do
      string = [:uses, :variable, :coma, :variable]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :uses_fold
    end
  end

  it 'value fold' do
    string = [:variable, :add, :real, :add, :integer, :add, :variable]

    cyk = Cyk.new(string, table)

    cyk.valid?.should be_true
    cyk.parse_tree.last.last.should == :value_fold
  end

  context 'common_expr_fold' do
    it 'simple right side' do
      string = [:variable, :assignement, :variable]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :common_expr_fold
    end

    it 'complex right side' do
      string = [:variable, :assignement, :variable, :add, :variable, :add, :integer]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :common_expr_fold
    end
  end

  context 'block_fold' do
    it 'with no statements' do
      string = [:begin, :end]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :block_fold
    end

    it 'with one statement' do
      string = [:begin, :variable, :assignement, :variable, :add, :variable, :add, :integer, :end]

      cyk = Cyk.new(string, table)

      cyk.valid?.should be_true
      cyk.parse_tree.last.last.should == :block_fold
    end

    it 'with several statements'
  end
end
