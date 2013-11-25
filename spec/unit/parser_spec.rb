require "spec_helper"
require "sie/parser"

describe Sie::Parser, "parse" do
  it "parses sie data that includes arrays" do
    parser = Sie::Parser.new
    sie_file = parser.parse(<<DATA
#VER "LF" 2222 20130101 "Foocorp expense"
{
#TRANS 2400 {} -200 20130101 "Foocorp expense"
#TRANS 4100 {} 180 20130101 "Widgets from foocorp"
#TRANS 2611 {} -20 20130101 "VAT"
}
DATA
    )

    voucher_entry = sie_file.entries.first
    expect(sie_file.entries.size).to eq(1)
    expect(voucher_entry.attributes["verdatum"]).to eq("20130101")
    expect(voucher_entry.entries.size).to eq(3)
    expect(voucher_entry.entries.first.attributes["kontonr"]).to eq("2400")
  end
end
