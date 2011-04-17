module Errors
  class InputMissingException < Exception
    def to_s
      'Input string is not given.'
    end
  end
end
