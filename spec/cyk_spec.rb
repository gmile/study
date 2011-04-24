require_relative '../lexical_analyser'
require_relative '../cyk'

# TODO: check if nterms have defined term symbol they can be derived from

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
      cyk.start_symbols.should == Set.new([:r4])
    end

    it 'should not bother if there are redundant rules' do
      redundant_rules = {
        :r4 => [[:r5, :r3], [:r2, :r3]],
        :r5 => [[:r1, :r2], [:r2, :r1]],
        :r6 => [[:r1, :r1]]
      }

      cyk = Cyk.new(string, table.merge(redundant_rules))
      cyk.valid?.should be_true
      cyk.start_symbols.should == Set.new([:r4, :r6])
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
    table  = {
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
    table  = {
      :t1  => [:variable   ],
      :t2  => [:assignement],
      :t3  => [:integer    ],
      :t4  => [:semicolon  ],
      :e1  => [[:t1, :t2]  ],
      :e2  => [[:e1, :t3]  ],
      :e3  => [[:e2, :t4]  ],
      :e4  => [[:e3, :e3]  ],
      :e5  => [[:e4, :e3]  ]
    }

    Cyk.new(string, table).valid?.should be_true
  end

  it 'should raise error if there are unknown nterminals in the right side' do
    string = Parser.new("a").output.map { |token| token.type }
    table  = {
      :t1  => [:variable],
      :e1  => [:t1, [:t1, :w]],
      :e2  => [:t1, :a, [:t1, :q]],
    }

    lambda { Cyk.new(string, table) }.should raise_error(Cyk::UnknownTokensException, 'Right side of table includes unknown tokens [:w, :a, :q]. Are all of them defined?')
  end

  it 'should raise NoStartSymbolsGivenException exception if that\' the case' do
    string = '1 + 2 / 3 + 5'.split(' ')
    table  = {
      :r1 => ['1', '2', '3', '5', [:r2, :r1]],
      :r2 => [[:r1, :r3]],
      :r3 => ['+', '/']
    }

    lambda { Cyk.new(string, table) }.should raise_error(Cyk::NoStartSymbolsGivenException, 'No start symbols given. Left side should include at least one token which is absent from the right side')
  end
end
