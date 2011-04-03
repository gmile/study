require_relative 'cyk'

describe Cyk do
  it 'should understand "program test ;" dumb string' do
    options = {
      :string => 'program test ;'.split(' '),
      :table  => {
        :r1 => 'program' ,
        :r2 => 'test'    ,
        :r3 => ';'       ,
        :r4 => [:r5, :r3],
        :r5 => [:r1, :r2]
      }
    }

    Cyk.new(options).valid?.should be_true
  end
end
