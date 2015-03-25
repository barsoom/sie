require "spec_helper"
require "sie/parser/build_entry"
require "sie/parser/tokenizer"

describe Sie::Parser::BuildEntry, ".call" do
  context "with an unexpected token at start of array" do
    it "raises InvalidEntryError" do
      line = '#TRANS 2400 [] -200 20130101 "Foocorp expense"'
      tokens = Sie::Parser::Tokenizer.new(line).tokenize
      first_token = tokens.shift

      expect {
        Sie::Parser::BuildEntry.call(line, first_token, tokens, false)
      }.to raise_error(Sie::Parser::BuildEntry::InvalidEntryError)
    end
  end
end
