require_relative '../lexical_analyser'
require_relative '../cyk'

describe Cyk do
  context '"program test ;"' do
    let(:string) { 'program test ;'.split }
    let(:table)  {
      {
        :r1 => ['program'],
        :r2 => ['test'   ],
        :r3 => [';'      ],
        :r4 => [[:r5, :r3]],
        :r5 => [[:r1, :r2]]
      }
    }

    it 'should prove that sentance can be generated over a given alphabet' do
      cyk = Cyk.new(string, table)
      cyk.valid?.should be_true
      cyk.start_symbols.should == Set.new([:r4, :r5])
    end

    it 'should not bother if there are redundant rules' do
      redundant_rules = {
        :r4 => [[:r5, :r3], [:r2, :r3]],
        :r5 => [[:r1, :r2], [:r2, :r1]],
        :r6 => [[:r1, :r1]]
      }

      cyk = Cyk.new(string, table.merge(redundant_rules))
      cyk.valid?.should be_true
      cyk.start_symbols.should == Set.new([:r4, :r5, :r6])
    end
  end

  context 'patterns' do
    let(:table) do
      {
        :r1 => [:a],
        :r2 => [:b],
        :r3 => [:c],
        :r4 => [:d],
        :r5 => [[:r2, :r3], [:r2, :r4], [:r5, :r5]],
        :r6 => [[:r1, :r5]]
      }
    end

    it '"Vars with coma" pattern' do
      string = [:a, :b, :c, :b, :d]

      Cyk.new(string, table).valid?.should be_true
    end

    it '"Single var" pattern' do
      string = [:a, :b, :d]

      Cyk.new(string, table).valid?.should be_true
    end
  end

  it 'should parse with a rule: R -> A A' do
    string = 'a b c d a b c d a b c d a'.split(' ')

    table = {
      :r1 => ['a'],
      :r2 => ['b'],
      :c1 => ['c'],
      :c2 => ['d'],
      :r3 => [[:r1, :r2], [:c1, :c2], [:r3, :r3]],
      :r4 => [[:r3, :r1]]
    }

    Cyk.new(string, table).valid?.should be_true
  end

  it 'should parse a real piece of program with reccurent produtions' do
    string = Parser.new("s := 10; s := 12; s := 14;").output.map { |token| token.type }

    table = {
      :t1 => [:variable   ],
      :t2 => [:assignement],
      :t3 => [:integer    ],
      :t4 => [:semicolon  ],
      :e1 => [[:t1, :t2]  ],
      :e2 => [[:e1, :t3]  ],
      :e3 => [[:e2, :t4]  ],
      :e4 => [[:e3, :e3]  ],
      :e5 => [[:e4, :e3]  ]
    }

    Cyk.new(string, table).valid?.should be_true
  end

  context 'types of rules' do
    let(:string) { [:a, :b, :c] }

    it 'should parse with: A -> [a, b, [C, D]] types of rules' do
      table = {
        :e1 => [:a, :b],
        :e2 => [:c, [:e1, :e1]],
        :e3 => [[:e2, :e2]]
      }

      cyk = Cyk.new(string, table)
      cyk.valid?.should be_true
      cyk.instance_variable_get(:@known_terminals).should == [:a, :b, :c]
    end

    it 'should parse with: A -> [[B, C]] types of rules' do
      table = {
        :e1 => [:a, :b, :c],
        :e2 => [[:e1, :e1]],
        :e3 => [[:e2, :e1]]
      }

      Cyk.new(string, table).valid?.should be_true
    end

    it 'should parse with: A -> [a, b, c] types of rules' do
      table = {
        :t1 => [:a, :b, :c],
        :e2 => [[:t1, :t1]],
        :e3 => [[:e2, :t1]]
      }

      Cyk.new(string, table).valid?.should be_true
    end

    it 'should parse with: A -> [a, a] types of rules' do
      string = [:a, :a, :a]

      table = {
        :e1 => [:a, :a],
        :e2 => [[:e1, :e1]],
        :e3 => [[:e2, :e1]]
      }

      cyk = Cyk.new(string, table)
      cyk.valid?.should be_true
      cyk.instance_variable_get(:@known_terminals).should == [:a]
    end

    it 'should parse with: A -> [a] types of rules' do
      string = [:a, :a, :a]

      table = {
        :e1 => [:a],
        :e2 => [[:e1, :e1]],
        :e3 => [[:e2, :e1]]
      }

      Cyk.new(string, table).valid?.should be_true
    end
  end

  context 'Build tree from: a b c' do
    let(:string) { [:a, :b, :c] }

    it 'forward strategy' do
      table = {
        :e1 => [:a, :b, :c],
        :e2 => [[:e1, :e2], [:e1, :e1]]
      }

      cyk = Cyk.new(string, table)
      cyk.valid?
      cyk.tree.should == [:e2, [:e1, [:e2, [:e1, :e1]]]]
    end

    it 'backward strategy' do
      table = {
        :e1 => [:a, :b, :c],
        :e2 => [[:e2, :e1], [:e1, :e1]]
      }

      cyk = Cyk.new(string, table)
      cyk.valid?
      cyk.tree.should == [:e2, [[:e2, [:e1, :e1]], :e1]]
    end
  end

  context 'Exceptions' do
    let(:string) { [:a, :b, :c, :d, :d] }
    let(:table) {
      {
        :e1 => [:a, :b, :c, :d],
        :e2 => [:e1, [:e1, :e3]]
      }
    }

    it 'should raise error if there are unknown non-terminals in the right side' do
      exception = Cyk::UnknownNonTerminalsException
      message   = 'Right side of table includes unknown non-terminals [:e3]. Are all of them defined?'

      lambda { Cyk.new(string, table) }.should raise_error(exception, message)
    end

    it 'should raise error if there are unknown terminals in the right side' do
      exception = Cyk::UnknownTerminalsException
      message   = 'Right side of table includes unknown terminals [:d]. Are all of them defined?'

      error_agent = {
        :e1 => [:a, :b, :c]
      }

      lambda { Cyk.new(string, table.merge(error_agent)) }.should raise_error(exception, message)
    end

    it 'should raise NoStartSymbolsGivenException exception if that\' the case' do
      exception = Cyk::NoPairProductionsException
      message   = 'No A -> BC productions given. Have you specified them?'

      error_agent = { :e2 => [:e1] }

      lambda { Cyk.new(string, table.merge(error_agent)) }.should raise_error(exception, message)
    end
  end
end
