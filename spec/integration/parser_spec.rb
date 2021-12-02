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

  context "with unknown entries" do
    let(:file_with_unknown_entries) { "fixtures/sie_file_with_unknown_entries.se" }

    context "using a lenient parser" do
      let(:parser) { Sie::Parser.new(lenient: true) }

      it "handles unknown entries without raising error" do
        open_file(file_with_unknown_entries) do |f|
          expect { parser.parse(f) }.not_to raise_error
        end
      end

      it "continues to parse the complete file after unknown entries" do
        open_file(file_with_unknown_entries) do |f|
          sie_file = parser.parse(f)

          expect(sie_file.entries_with_label("ver").size).to eq(2)
        end
      end
    end

    context "with strict parser" do
      let(:parser) { Sie::Parser.new }

      it "raises error when encountering unknown entries" do
        open_file(file_with_unknown_entries) do |f|
          expect { parser.parse(f) }.to raise_error(/Unknown entry type: momskod.+Pass 'lenient: true'/)
        end
      end
    end
  end

  def open_file(fixture_file, &block)
    File.open(File.join(__dir__, "../#{fixture_file}"), &block)
  end
end
