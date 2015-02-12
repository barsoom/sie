require "strscan"
require "sie/parser/tokenizer/token"
require "sie/parser/tokenizer/character"

module Sie
  class Parser
    class Tokenizer
      pattr_initialize :line

      def tokenize
        @tokens = []
        @consume = false
        @quoted = false

        loop do
          move_to_next_character
          break unless current_character.value

          if consume? && !current_character.end_of_array?
            if quoted?
              consume_quoted_value
            else
              consume_unquoted_value
            end
          else
            add_new_token
          end
        end

        tokens
      end

      private

      attr_query :consume?, :quoted?
      attr_private :consume, :quoted, :tokens, :current_character

      def move_to_next_character
        @current_character = Character.new(scanner.getch)
      end

      def consume_quoted_value
        if current_character.quote?
          @quoted = false
        else
          add_to_current_token current_character
        end
      end

      def consume_unquoted_value
        if current_character.unquoted_data?
          add_to_current_token current_character
        else
          @consume = false
        end
      end

      def add_new_token
        if current_character.entry?
          @consume = true
          add_token EntryToken.new
        elsif current_character.beginning_of_array?
          add_token BeginArrayToken.new
        elsif current_character.end_of_array?
          add_token EndArrayToken.new
        elsif current_character.quote?
          @consume = @quoted = true
          add_token StringToken.new
        elsif current_character.non_whitespace?
          @consume = true
          add_token StringToken.new(current_character.value)
        elsif current_character.value != " "
          raise "Unhandled character: #{current_character.value}"
        end
      end

      def add_token(token)
        tokens << token
      end

      def add_to_current_token(character)
        tokens.last.value += character.value
      end

      def scanner
        @scanner ||= StringScanner.new(line)
      end
    end
  end
end
