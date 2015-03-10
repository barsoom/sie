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

        attributes_with_tokens(entry_type).each do |attr, *attr_tokens|
          label = attr.is_a?(Hash) ? attr[:name] : attr
          if attr_tokens.size == 1
            entry.attributes[label] = attr_tokens.first
          else
            values = attr_tokens.each_slice(attr[:type].size).map { |slice| Hash[attr[:type].zip(slice)] }
            entry.attributes[label] = values
          end
        end

        entry
      end

      def attributes_with_tokens(line_entry_type)
        line_entry_type.map { |attr_entry_type|
          if attr_entry_type.is_a?(String)
            token = tokens.shift
            next unless token
            [attr_entry_type, token.value]
          else
            token = tokens.shift
            if !token.is_a?(Tokenizer::BeginArrayToken)
              raise "ERROR"
            end

            hash_tokens = []
            while token = tokens.shift
              break if token.is_a?(Tokenizer::EndArrayToken)
              hash_tokens << token.value
            end

            [attr_entry_type, *hash_tokens]
          end
        }.compact
      end

      def build_empty_entry
        Entry.new(first_token.label)
      end

      def raise_invalid_entry_error
        raise InvalidEntryError, "Unknown entry type: #{first_token.label}"
      end
    end
  end
end
