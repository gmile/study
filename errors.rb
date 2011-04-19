module Errors
  module Parser
    class InputMissingException < Exception
      def to_s; 'Nothing to parse. Was input string given?' end
    end

    class NoOutputPerformedException < Exception
      def to_s; 'No tokens to validate. Was output performed?' end
    end
  end

  module Cyk
    class UnknownTokensException < Exception
      def to_s; 'Right side of table includes unknown tokens. Are all of them defined?' end
    end

    class NoStartSymbolsGivenException < Exception
      def to_s; 'No start symbols given. Left side should include at least one token which is absent from the right side' end
    end
  end
end
