require "spec_helper"
require "sie/parser/tokenizer"

describe Sie::Parser::Tokenizer do
  it "tokenizes the given line" do
    tokenizer = Sie::Parser::Tokenizer.new('#TRANS 2400 {} -200 20130101 "Foocorp expense"')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
      [ "EntryToken", "TRANS" ],
      [ "StringToken", "2400" ],
      [ "BeginArrayToken", "" ],
      [ "EndArrayToken", "" ],
      [ "StringToken", "-200" ],
      [ "StringToken", "20130101" ],
      [ "StringToken", "Foocorp expense" ]
    ])
  end

  it "can parse metadata arrays" do
    tokenizer = Sie::Parser::Tokenizer.new('#TRANS 2400 { 1 "2" } -200 20130101 "Foocorp expense"')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
      [ "EntryToken", "TRANS" ],
      [ "StringToken", "2400" ],
      [ "BeginArrayToken", "" ],
      [ "StringToken", "1" ],
      [ "StringToken", "2" ],
      [ "EndArrayToken", "" ],
      [ "StringToken", "-200" ],
      [ "StringToken", "20130101" ],
      [ "StringToken", "Foocorp expense" ]
    ])
  end

  def token_table_for(tokens)
    tokens.map { |token|
      [ token.class.name.split("::").last, token.value ]
    }
  end
end
