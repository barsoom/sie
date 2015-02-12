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

        ti = ai = 0
        while ti < tokens.size && ai < entry_type.size
          attr_entry_type = entry_type[ai]

          if attr_entry_type.is_a?(Hash)
            label = attr_entry_type[:name]
            type = attr_entry_type[:type]
            entry.attributes[label] ||= []

            ti += 1
            hash_tokens = []
            while !tokens[ti].is_a?(Sie::Parser::Tokenizer::EndArrayToken)
              hash_tokens << tokens[ti].value
              ti += 1
            end

            hash_tokens.each_slice(type.size).each do |slice|
              entry.attributes[label] << Hash[type.zip(slice)]
            end
          else
            label = attr_entry_type
            entry.attributes[label] = tokens[ti].value
          end

          ti += 1
          ai += 1
        end

        entry
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
