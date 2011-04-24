require_relative '../cnf_table'
require_relative '../cyk'

describe Cyk do
  it "should raise error if no A -> B C rules given" do
    CNFTable.stub(:non_terminals).and_return({})

    string = [:program, :variable, :semicolon]

    lambda { Cyk.new(string, CNFTable.table) }.should raise_error(Cyk::NoPairProductionsException, 'No A -> BC productions given. Have you specified them?')
  end

  context 'CNF Table' do
    let!(:table) { CNFTable.table }

    it "should raise error if no A -> B C rules given" do
      string = [:program, :variable, :semicolon]

      Cyk.new(string, table).valid?.should be_true
    end

    it "should parse 'uses' block with only one arg" do
      string = [:uses, :variable, :semicolon]

      Cyk.new(string, table).valid?.should be_true
    end

    it "should parse 'uses' block with several args" do
      string = [:uses, :variable, :coma, :variable, :semicolon]

      Cyk.new(string, table).valid?.should be_true
    end
  end
end
