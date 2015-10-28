require "strscan"
require "sie/parser/tokenizer/token"

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
          when match = find_entry
            tokens << EntryToken.new(match)
          when begin_array?
            tokens << BeginArrayToken.new
          when end_array?
            tokens << EndArrayToken.new
          when match = find_string
            tokens << StringToken.new(match)
          when end_of_string?
            break
          else
            # We shouldn't get here, but if we do we need to bail out, otherwise we get an infinite loop.
            fail "Unhandled character in line at position #{scanner.pos}: " + scanner.string
          end
        end

        tokens
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

      def find_entry
        match = scanner.scan(/#\S+/)

        if match
          match.sub(/\A#/, "")
        else
          nil
        end
      end

      def begin_array?
        scanner.scan(/#{Sie::Parser::BEGINNING_OF_ARRAY}/)
      end

      def end_array?
        scanner.scan(/#{Sie::Parser::END_OF_ARRAY}/)
      end

      def find_string
        match = find_quoted_string || find_unquoted_string

        if match
          remove_unnecessary_escapes(match)
        else
          nil
        end
      end

      def end_of_string?
        scanner.eos?
      end

      def find_quoted_string
        match = scanner.scan(/"(\\"|[^"])*"/)

        if match
          match.sub(/\A"/, "").sub(/"\z/, "")
        else
          nil
        end
      end

      def find_unquoted_string
        scanner.scan(/\S+/)
      end

      def remove_unnecessary_escapes(match)
        match.gsub(/\\([\\"])/, "\\1")
      end

      def scanner
        @scanner ||= StringScanner.new(line)
      end
    end
  end
end
