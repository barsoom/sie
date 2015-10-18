require "strscan"
require "sie/parser/tokenizer/token"
require "sie/parser/tokenizer/character"

module Sie
  class Parser
    class Tokenizer
      pattr_initialize :line

      def tokenize
        tokens = []
        check_for_control_characters

        loop do
          case
            when whitespace?
              next

            when match = entry?
              tokens << EntryToken.new(match)

            when begin_array?
              tokens << BeginArrayToken.new

            when end_array?
              tokens << EndArrayToken.new

            when match = quoted_string?
              tokens << StringToken.new(match)

            when match = string?
              tokens << StringToken.new(match)

            when end_of_string?
              return tokens

            else
              # We shouldn't get here, but if we do we need to bail out, otherwise we get an infinite loop.
              fail "Unhandled character in line at position #{scanner.pos}: " + scanner.string
          end
        end
      end

      private

      def check_for_control_characters
        if /(.*?)([\x00-\x08\x0a-\x1f\x7f])/.match(line)
          fail "Unhandled character in line at position #{$1.length + 1}: " + scanner.string
        end
      end

      def whitespace?
        scanner.scan(/[ \t]+/)
      end

      def entry?
        match = scanner.scan(/#\S+/)
        if match
          match.sub!(/\A#/, "")
        end
      end

      def begin_array?
        scanner.scan(/{/)
      end

      def end_array?
        scanner.scan(/}/)
      end

      def quoted_string?
        match = scanner.scan(/"(\\"|[^"])*"/)

        if match
          match.sub!(/\A"/, "")
          match.sub!(/"\z/, "")
          match.gsub!(/\\"/, "\"")
          match
        end
      end

      def string?
        scanner.scan(/\S+/)
      end

      def end_of_string?
        scanner.eos?
      end

      def scanner
        @scanner ||= StringScanner.new(line)
      end
    end
  end
end
