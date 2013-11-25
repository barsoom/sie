# encoding: utf-8

require "spec_helper"

describe Sie::Parser do
  it "parses a file" do
    parser = Sie::Parser.new

    open_file("fixtures/sie_file.se") do |f|
      sie_file = parser.parse(f)

      expect(sie_file.entries_with_label("fnamn").first.attributes["foretagsnamn"]).to eq("Foocorp")

      account = sie_file.entries_with_label("konto").first
      expect(account.attributes["kontonr"]).to eq("1510")
      expect(account.attributes["kontonamn"]).to eq("Accounts receivable")
      expect(sie_file.entries_with_label("ver").size).to eq(2)
    end
  end

  def open_file(fixture_file)
    File.open(File.join(File.dirname(__FILE__), "../#{fixture_file}"))
  end
end
