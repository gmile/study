require_relative 'cyk'

describe Cyk do
  context '"program test ;"' do
    before :each do
      @options = {
        :string => 'program test ;'.split(' '),
        :table  => {
          :r1 => ['program'],
          :r2 => ['test'   ],
          :r3 => [';'      ],
          :r4 => [[:r5, :r3], [:r2, :r3]],
          :r5 => [[:r1, :r2], [:r2, :r1]]
        }
      }
    end

    it 'should prove that sentance can be generated over a given alphabet' do
      Cyk.new(@options).valid?.should be_true
    end

    it 'should not bother if there are redundant strings' do
      @options[:table].merge!({
        :r4 => [[:r5, :r3], [:r2, :r3]],
        :r5 => [[:r1, :r2], [:r2, :r1]]
      })

      Cyk.new(@options).valid?.should be_true
    end
  end

  it 'should parse a real piece of program' do
    options = {
      :string => '1 + 2 / 3 + 5'.split(' '),
      :table  => {
        :r1 => ['1', '2', '3', '5', [:r2, :r1]],
        :r2 => [[:r1, :r3]],
        :r3 => ['+', '-', '*', '/']
      }
    }

    Cyk.new(options).valid?.should be_true
  end
end
