require "sie/parser/tokenizer"
require "sie/parser/entry"
require "sie/parser/sie_file"

module Sie
  class Parser
    class LineParser
      pattr_initialize :line

      def parse
        tokens = tokenize(line)
        first_token = tokens.shift

        entry = Entry.new(first_token.label)
        entry_type = first_token.entry_type

        entry_type.each_with_index do |entry_type, i|
          break if i >= tokens.size

          if entry_type.is_a?(Hash)
            skip_array(tokens, i)
            next
          else
            label = entry_type
            entry.attributes[label] = tokens[i].value
          end
        end

        entry
      end

      private

      def tokenize(line)
        Tokenizer.new(line).tokenize
      end

      def skip_array(tokens, i)
        if tokens[i].is_a?(Tokenizer::BeginArrayToken) &&
         !tokens[i+1].is_a?(Tokenizer::EndArrayToken)
          raise "We currently don't support metadata within entries as we haven't had a need for it yet (the data between {} in #{line})."
        end

        tokens.reject! { |token| token.is_a?(Tokenizer::EndArrayToken) }
      end
    end
  end
end
