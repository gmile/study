require_relative '../cnf_table'
require_relative '../cyk'

describe Cyk do
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

  it "should parse 'begin' block without inner values" do
    string = [:begin, :end]

    Cyk.new(string, table).valid?.should be_true
  end

  it "should parse 'begin' block without inner values" do
    string = [:variable, :assignement, :variable, :add, :variable]

    Cyk.new(string, table).valid?.should be_true
  end
end
