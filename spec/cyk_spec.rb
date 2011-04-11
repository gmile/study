require_relative '../cyk'
require_relative '../lexical_analyser'

describe Cyk do
  context '"program test ;"' do
    before :each do
      @options = {
        :string => 'program test ;'.split(' '),
        :table  => {
          :r1 => ['program'],
          :r2 => ['test'   ],
          :r3 => [';'      ],
          :r4 => [[:r5, :r3]],
          :r5 => [[:r1, :r2]]
        }
      }
    end

    it 'should prove that sentance can be generated over a given alphabet' do
      Cyk.new(@options).valid?.should be_true
    end

    it 'should not bother if there are redundant rules' do
      @options[:table].merge!({
        :r4 => [[:r5, :r3], [:r2, :r3]],
        :r5 => [[:r1, :r2], [:r2, :r1]],
        :r6 => ['2', [:r1, :r1]]
      })

      Cyk.new(@options).valid?.should be_true
    end
  end

  context "start_symbols_from" do
    before :each do
      @options = {
        :string => 'program test ;'.split(' '),
        :table => {
          :r1 => ['program'],
          :r2 => ['test'   ],
          :r3 => [';'      ],
          :r4 => [[:r1, :r3], [:r2, :r3]],
          :r5 => [[:r1, :r2], [:r3, :r5]]
        }
      }
    end

    it "should find no start symbols" do
      @options[:table].merge!({ :r4 => [[:r4, :r1]] })

      Cyk.new(@options).start_symbols.should == Set.new
    end

    it "should find one start symbol" do
      Cyk.new(@options).start_symbols.should == Set.new([:r4])
    end

    it "should find two start symbols" do
      @options[:table].merge!({ :r6 => [[:r1, :r2]] })

      Cyk.new(@options).start_symbols.should == Set.new([:r4, :r6])
    end
  end

  it 'should parse numerical expression' do
    options = {
      :string => '1 + 2 / 3 + 5'.split(' '),
      :table  => {
        :r1 => ['1', '2', '3', '5', [:r2, :r1]],
        :r2 => [[:r1, :r3]],
        :r3 => ['+', '-', '*', '/']
      }
    }
    # no start symbols here...
    Cyk.new(options).valid?.should be_true
  end

  it 'should parse with a rule: R -> A A' do
    @options = {
      :string => 'a b c d'.split(' '),
      :table  => {
        :r1 => ['a'],
        :r2 => ['b'],
        :r3 => ['c'],
        :r4 => ['d'],
        :r5 => [[:r1, :r2], [:r3, :r4]],
        :r6 => [[:r5, :r5]]
      }
    }

    x = Cyk.new(@options)
    result = x.valid?
    result.should be_true
  end

  it 'should parse with a rule: R -> A A' do
    @options = {
      :string => 'a b c d a b c d a b c d a'.split(' '),
      :table  => {
        :r1 => ['a'],
        :r2 => ['b'],
        :c1 => ['c'],
        :c2 => ['d'],
        :r3 => [[:r1, :r2], [:c1, :c2], [:r3, :r3]],
        :r4 => [[:r3, :r1]]
      }
    }

    Cyk.new(@options).valid?.should be_true
  end

  it 'should parse a real piece of program with reccurent produtions' do
    source_code = <<-eos
      s := 10; s := 12; s := 14;
    eos

    @parser = Parser.new(source_code)
    @parser.divide
    @parser.tokenize

    string = @parser.output.flatten.map { |token| token.type }

    options = {
      :string => string,
      :table  => {
        :t1  => [:user_data],
        :t2  => [:assignement],
        :t3  => [:number],
        :t4  => [:colon],
        :e1  => [[:t1, :t2]],
        :e2  => [[:e1, :t3]],
        :e3  => [[:e2, :t4]],
        :e4  => [[:e3, :e3]],
        :e5  => [[:e4, :e3]]
      }
    }

    x = Cyk.new(options)
    result = x.valid?
    result.should be_true
  end
end