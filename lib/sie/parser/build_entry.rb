module Sie
  class Parser
    class BuildEntry
      method_object :line, :first_token, :tokens, :lenient

      InvalidEntryError = Class.new(StandardError)

      def call
        if first_token.known_entry_type?
          build_complete_entry
        elsif lenient
          build_empty_entry
        else
          raise_invalid_entry_error
        end
      end

      private

      def build_complete_entry
        entry = build_empty_entry
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

      def build_empty_entry
        Entry.new(first_token.label)
      end

      def raise_invalid_entry_error
        raise InvalidEntryError, "Unknown entry type: #{first_token.label}"
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
