module Sie
  class Parser
    class Tokenizer
      class Character
        pattr_initialize :value
        attr_reader :value

        def unquoted_data?
          non_whitespace? && !end_of_array?
        end

        def entry?
          value == "#"
        end

        def beginning_of_array?
          value == "{"
        end

        def end_of_array?
          value == "}"
        end

        def quote?
          value == '"'
        end

        def non_whitespace?
          value != " " && value != "\t"
        end
      end
    end
  end
end
