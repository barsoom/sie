require "sie/parser/tokenizer"
require "sie/parser/entry"
require "sie/parser/sie_file"
require "sie/parser/build_entry"

module Sie
  class Parser
    class LineParser
      pattr_initialize :line, [ :lenient ]

      def parse
        tokens = tokenize(line)
        first_token = tokens.shift
        build_entry(first_token, tokens)
      end

      private

      def tokenize(line)
        Tokenizer.new(line).tokenize
      end

      def build_entry(first_token, tokens)
        BuildEntry.call(line, first_token, tokens, lenient)
      end
    end
  end
end
