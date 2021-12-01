require "spec_helper"
require "sie/parser/line_parser"

describe Sie::Parser::LineParser, "parse" do
  it "parses lines from a sie file" do
    parser = Sie::Parser::LineParser.new('#TRANS 2400 {"3" "5"} -200 20130101 "Foocorp expense"')
    entry = parser.parse
    expect(entry.label).to eq("trans")
    expect(entry.attributes).to eq({
      "kontonr" => "2400",
      "belopp"  => "-200",
      "transdat" => "20130101",
      "transtext" => "Foocorp expense",
      "objektlista" => [ { "dimensionsnr" => "3", "objektnr" => "5" } ],
    })
  end

  context "with unknown entry" do
    let(:line) { "#MOMSKOD 2611 10" }

    context "using a lenient parser" do
      let(:parser) { Sie::Parser::LineParser.new(line, lenient: true) }

      it "raises no error when encountering unknown entries" do
        expect { parser.parse }.not_to raise_error
      end
    end

    context "using a strict parser" do
      let(:parser) { Sie::Parser::LineParser.new(line) }

      it "raises error when encountering unknown entries" do
        expect { parser.parse }.to raise_error(/Unknown entry type/)
      end
    end
  end
end
