require "sie/parser/entry_types"

module Sie
  class Parser
    class Tokenizer
      class Token
        attr_accessor :value

        def initialize(value = "")
          @value = value
        end

        def known_entry_type?
          Sie::Parser::ENTRY_TYPES.has_key?(label)
        end

        def entry_type
          Sie::Parser::ENTRY_TYPES.fetch(label)
        end

        def label
          value.sub(/^#/, '').downcase
        end
      end

      class EntryToken < Token; end
      class BeginArrayToken < Token; end
      class EndArrayToken < Token; end
      class StringToken < Token; end
      class ArrayToken < Token; end
    end
  end
end
