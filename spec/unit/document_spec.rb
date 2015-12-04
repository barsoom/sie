# encoding: utf-8
require "spec_helper"
require "sie"
require "active_support/core_ext/date/calculations"

describe Sie::Document, "#render" do
  let(:financial_years) {
    [
      Date.new(2011, 1, 1)..Date.new(2011, 12, 31),
      Date.new(2012, 1, 1)..Date.new(2012, 12, 31),
      Date.new(2013, 1, 1)..Date.new(2013, 12, 31),
    ]
  }
  let(:generated_on) { Date.yesterday }
  let(:accounts) {
    [
      number: 1500, description: "Customer ledger",
    ]
  }
  let(:vouchers) {
    [
      {
        creditor: false, type: :invoice, number: 1, booked_on: Date.new(2011, 9, 3), description: "Invoice 1",
        voucher_lines: [
          {
            account_number: 1500, amount: 512.0, booked_on: Date.new(2011, 9, 3), description: "Item 1",
            dimensions: { 6 => 1 }
          },
          {
            account_number: 3100, amount: -512.0, booked_on: Date.new(2011, 9, 3), description: "Item 1",
            dimensions: { 6 => 1 }
          },
        ]
      },
      {
        creditor: true, type: :payment, number: 2, booked_on: Date.new(2012, 8, 31), description: "Payout 1",
        voucher_lines: [
          {
            account_number: 2400, amount: 256.0, booked_on: Date.new(2012, 8, 31), description: "Payout line 1"
          },
          {
            account_number: 1970, amount: -256.0, booked_on: Date.new(2012, 8, 31), description: "Payout line 2"
          },
        ]
      }
    ]
  }
  let(:dimensions) {
    [
      {
        number: 6, description: "Project",
        objects: [
          { number: 1, description: "Education" }
        ]
      }
    ]
  }

  class TestDataSource
    attr_accessor :program, :program_version, :generated_on, :company_name,
      :accounts, :balance_account_numbers, :closing_account_numbers,
      :vouchers, :financial_years, :dimensions

    # vouchers is not part of the expected interface so making it private.
    #
    # Sie::Document uses #each_voucher so that you can build documents for huge sets of vouchers
    # by loading them in batches.
    private :vouchers

    def initialize(hash)
      hash.each do |k, v|
        public_send("#{k}=", v)
      end
    end

    def each_voucher(&block)
      vouchers.each(&block)
    end

    def balance_before(account_number, date)
      if account_number == 9999
        # So we can test empty balances.
        nil
      else
        # Faking a fetch based on date and number.
        account_number.to_i + (date.mday * 100).to_f
      end
    end
  end

  let(:doc) {
    data_source = TestDataSource.new(
      accounts: accounts,
      vouchers: vouchers,
      program: "Foonomic",
      program_version: "3.11",
      generated_on: generated_on,
      company_name: "Foocorp",
      financial_years: financial_years,
      balance_account_numbers: [ 1500, 2400, 9999 ],
      closing_account_numbers: [ 3100, 9999 ],
      dimensions: dimensions
    )
    Sie::Document.new(data_source)
  }

  let(:sie_file) { Sie::Parser.new.parse(doc.render) }

  it "adds a header" do
    expect(entry_attribute("flagga",  "x")).to            eq("0")
    expect(entry_attribute("program", "programnamn")).to  eq("Foonomic")
    expect(entry_attribute("program", "version")).to      eq("3.11")
    expect(entry_attribute("format",  "PC8")).to          eq("PC8")
    expect(entry_attribute("gen",     "datum")).to        eq(generated_on.strftime("%Y%m%d"))
    expect(entry_attribute("sietyp",  "typnr")).to        eq("4")
    expect(entry_attribute("fnamn",   "foretagsnamn")).to eq("Foocorp")
  end

  it "has accounting years" do
    expect(indexed_entry_attribute("rar", 0, "arsnr")).to eq("0")
    expect(indexed_entry_attribute("rar", 0, "start")).to eq("20130101")
    expect(indexed_entry_attribute("rar", 0, "slut")).to  eq("20131231")
    expect(indexed_entry_attribute("rar", 1, "arsnr")).to eq("-1")
    expect(indexed_entry_attribute("rar", 1, "start")).to eq("20120101")
    expect(indexed_entry_attribute("rar", 1, "slut")).to  eq("20121231")
    expect(indexed_entry_attribute("rar", 2, "arsnr")).to eq("-2")
    expect(indexed_entry_attribute("rar", 2, "start")).to eq("20110101")
    expect(indexed_entry_attribute("rar", 2, "slut")).to  eq("20111231")
  end

  it "has accounts" do
    expect(indexed_entry_attributes("konto", 0)).to eq("kontonr" => "1500", "kontonamn" => "Customer ledger")
  end

  it "has dimensions" do
    expect(indexed_entry_attributes("dim", 0)).to eq("dimensionsnr" => "6", "namn" => "Project")
  end

  it "has objects" do
    expect(indexed_entry_attributes("objekt", 0)).to eq("dimensionsnr" => "6", "objektnr" => "1", "objektnamn" => "Education")
  end

  it "has balances brought forward (ingående balans)" do
    expect(indexed_entry_attributes("ib", 0)).not_to eq("arsnr" =>  "0", "konto" => "9999", "saldo" => "")
    expect(indexed_entry_attributes("ib", 0)).to     eq("arsnr" =>  "0", "konto" => "1500", "saldo" => "1600.0")
    expect(indexed_entry_attributes("ib", 1)).to     eq("arsnr" =>  "0", "konto" => "2400", "saldo" => "2500.0")
    expect(indexed_entry_attributes("ib", 2)).to     eq("arsnr" => "-1", "konto" => "1500", "saldo" => "1600.0")
    expect(indexed_entry_attributes("ib", 3)).to     eq("arsnr" => "-1", "konto" => "2400", "saldo" => "2500.0")
    expect(indexed_entry_attributes("ib", 4)).to     eq("arsnr" => "-2", "konto" => "1500", "saldo" => "1600.0")
    expect(indexed_entry_attributes("ib", 5)).to     eq("arsnr" => "-2", "konto" => "2400", "saldo" => "2500.0")
  end

  it "has balances carried forward (utgående balans)" do
    expect(indexed_entry_attributes("ub", 0)).not_to eq("arsnr" =>  "0", "konto" => "9999", "saldo" => "")
    expect(indexed_entry_attributes("ub", 0)).to     eq("arsnr" =>  "0", "konto" => "1500", "saldo" => "4600.0")
    expect(indexed_entry_attributes("ub", 1)).to     eq("arsnr" =>  "0", "konto" => "2400", "saldo" => "5500.0")
    expect(indexed_entry_attributes("ub", 2)).to     eq("arsnr" => "-1", "konto" => "1500", "saldo" => "4600.0")
    expect(indexed_entry_attributes("ub", 3)).to     eq("arsnr" => "-1", "konto" => "2400", "saldo" => "5500.0")
    expect(indexed_entry_attributes("ub", 4)).to     eq("arsnr" => "-2", "konto" => "1500", "saldo" => "4600.0")
    expect(indexed_entry_attributes("ub", 5)).to     eq("arsnr" => "-2", "konto" => "2400", "saldo" => "5500.0")
  end

  it "has closing account balances (saldo för resultatkonto)" do
    expect(indexed_entry_attributes("res", 0)).not_to eq("ars" =>  "0", "konto" => "9999", "saldo" =>  "")
    expect(indexed_entry_attributes("res", 0)).to     eq("ars" =>  "0", "konto" => "3100", "saldo" =>  "6200.0")
    expect(indexed_entry_attributes("res", 1)).to     eq("ars" => "-1", "konto" => "3100", "saldo" =>  "6200.0")
    expect(indexed_entry_attributes("res", 2)).to     eq("ars" => "-2", "konto" => "3100", "saldo" =>  "6200.0")
  end

  it "has vouchers" do
    expect(indexed_entry("ver", 0).attributes).to eq(
      "serie" => "KF", "vernr" => "1",
      "verdatum" => "20110903", "vertext" => "Invoice 1"
    )
    expect(indexed_voucher_entries(0)[0].attributes).to eq(
      "kontonr" => "1500", "belopp" =>  "512.0",
      "transdat" => "20110903", "transtext" => "Item 1",
      "objektlista" => [{"dimensionsnr" => "6", "objektnr" => "1"}]
    )
    expect(indexed_voucher_entries(0)[1].attributes).to eq(
      "kontonr" => "3100", "belopp" => "-512.0",
      "transdat" => "20110903", "transtext" => "Item 1",
      "objektlista" => [{"dimensionsnr" => "6", "objektnr" => "1"}]
    )

    expect(indexed_entry("ver", 1).attributes).to eq(
      "serie" => "KB", "vernr" => "2",
      "verdatum" => "20120831", "vertext" => "Payout 1"
    )
    expect(indexed_voucher_entries(1)[0].attributes).to eq(
      "kontonr" => "2400", "belopp" =>  "256.0",
      "transdat" => "20120831", "transtext" => "Payout line 1",
      "objektlista" => []
    )
    expect(indexed_voucher_entries(1)[1].attributes).to eq(
      "kontonr" => "1970", "belopp" => "-256.0",
      "transdat" => "20120831", "transtext" => "Payout line 2",
      "objektlista" => []
    )
  end

  context "with really long descriptions" do
    let(:accounts) {
      [
        number: 1500, description: "quack" * 50  # Make sure that the description exceeds the limit (200 chars).
      ]
    }
    let(:vouchers) {
      [
        build_voucher(
          description: "quiff" * 50,
          voucher_lines: [
            build_voucher_line(description: "quaff" * 50),
            build_voucher_line(description: "Payout line 2"),
          ]
        )
      ]
    }

    it "truncates the descriptions" do
      expect(indexed_entry_attributes("konto", 0)).to eq("kontonr" => "1500", "kontonamn" => "quack" * 40)
      expect(indexed_entry("ver", 0).attributes["vertext"]).to eq("quiff" * 40)
      expect(indexed_voucher_entries(0)[0].attributes["transtext"]).to eq("quaff" * 40)
    end
  end

  context "with a zeroed single voucher line" do
    let(:vouchers) {
      [
        build_voucher(voucher_lines: [ build_voucher_line(amount: 0) ])
      ]
    }

    it "ensures there are at least two lines" do
      expect(indexed_voucher_entries(0).size).to eq(2)
    end
  end

  context "with a series defined" do
    let(:vouchers) {
      [
        build_voucher(series: "X"),
      ]
    }

    it "reads the series from the voucher" do
      expect(indexed_entry("ver", 0).attributes["serie"]).to eq("X")
    end
  end

  private

  def build_voucher(attributes)
    defaults = {
      creditor: true,
      type: :payment,
      number: 1,
      booked_on: Date.today,
      description: "A voucher",
      voucher_lines: [
        build_voucher_line,
        build_voucher_line,
      ],
    }
    defaults.merge(attributes)
  end

  def build_voucher_line(attributes = {})
    defaults = { account_number: 1234, amount: 1, booked_on: Date.today, description: "A voucher line" }
    defaults.merge(attributes)
  end

  def entry_attribute(label, attribute)
    indexed_entry_attribute(label, 0, attribute)
  end

  def indexed_entry_attribute(label, index, attribute)
    indexed_entry_attributes(label, index).fetch(attribute) do
      raise "Unknown attribute #{ attribute } in #{ entry.attributes.keys.inspect }"
    end
  end

  def indexed_entry_attributes(label, index)
    indexed_entry(label, index).attributes
  end

  def indexed_voucher_entries(index)
    indexed_entry("ver", index).entries
  end

  def indexed_entry(label, index)
    sie_file.entries_with_label(label)[index] or raise "No entry with label #{ label.inspect } found!"
  end
end
