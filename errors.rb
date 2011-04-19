module Errors
  class InputMissingException < Exception
    def to_s; 'Nothing to parse. Was input string given?' end
  end

  class NoOutputPerformedException < Exception
    def to_s; 'No tokens to validate. Was output performed?' end
  end
end
