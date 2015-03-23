require "spec_helper"
require "sie/parser/build_entry"
require "sie/parser/tokenizer"

module Sie
  class Parser
    describe BuildEntry, "call" do
      context "with an unexpected token at start of array" do
        it "raises InvalidEntryError" do
          line = '#TRANS 2400 [] -200 20130101 "Foocorp expense"'
          tokens = Tokenizer.new(line).tokenize
          first_token = tokens.shift
          build_entry = BuildEntry.new(line, first_token, tokens, false)

          expect { build_entry.call }.to raise_error(BuildEntry::InvalidEntryError)
        end
      end
    end
  end
end
