require_relative '../cnf_table'
require_relative '../cyk'

describe Cyk do
  it "should raise error if no A -> B C rules given" do
    CNFTable.stub(:non_terminals).and_return({})

    @options = {
      :table => CNFTable.table,
      :string => [:program, :variable, :semicolon]
    }

    lambda { Cyk.new(@options) }.should raise_error(Cyk::NoPairProductionsException, 'No A -> BC productions given. Have you specified them?')
  end

  it "should raise error if no A -> B C rules given" do
    @options = {
      :table => CNFTable.table,
      :string => [:program, :variable, :semicolon]
    }

    Cyk.new(@options).valid?.should be_true
  end
end
