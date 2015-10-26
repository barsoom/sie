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

  it "handles escaped quotes in quoted strings" do
    tokenizer = Sie::Parser::Tokenizer.new('"String with \\" quote"')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
                                              [ "StringToken", 'String with " quote']
                                          ])
  end

  it "handles escaped quotes in non-quoted strings" do
    tokenizer = Sie::Parser::Tokenizer.new('String_with_\\"_quote')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
                                              [ "StringToken", 'String_with_"_quote']
                                          ])
  end

  it "handles escaped backslash in strings" do
    tokenizer = Sie::Parser::Tokenizer.new('"String with \\\\ backslash"')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
                                              [ "StringToken", 'String with \\ backslash']
                                          ])
  end

  it "has reasonable behavior for consecutive escape characters" do
    tokenizer = Sie::Parser::Tokenizer.new('"\\\\\\"\\\\"')
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
                                              [ "StringToken", '\\"\\']
                                          ])

  end

  it "handles tab character as field separator" do
    tokenizer = Sie::Parser::Tokenizer.new("#TRANS\t2400")
    tokens = tokenizer.tokenize

    expect(token_table_for(tokens)).to eq([
                                              [ "EntryToken", "TRANS"],
                                              [ "StringToken", "2400"]
                                          ])
  end

  it "rejects control characters" do
    codes_not_allowed = (0..8).to_a + (10..31).to_a + [127]
    codes_not_allowed.each do |x|
      tokenizer = Sie::Parser::Tokenizer.new([x].pack("C"))
      expect{tokenizer.tokenize}.to raise_error /Unhandled character/
    end
  end

  private

  def token_table_for(tokens)
    tokens.map { |token|
      [ token.class.name.split("::").last, token.value ]
    }
  end
end
