require "spec_helper"

describe Sie::FinancialYears, ".between" do
  it "gives us the financial years between from_date and to_date" do
    Sie::FinancialYears.between(
      Date.new(2011, 1, 1),
      Date.new(2011, 12, 31),
      start_month: 1,
    ).should == [
      Date.new(2011, 1, 1)..Date.new(2011, 12, 31)
    ]
  end

  it "gives us the financial years over multiple years" do
    Sie::FinancialYears.between(
      Date.new(2011, 9, 1),
      Date.new(2013, 12, 31),
      start_month: 1,
    ).should == [
      Date.new(2011, 1, 1)..Date.new(2011, 12, 31),
      Date.new(2012, 1, 1)..Date.new(2012, 12, 31),
      Date.new(2013, 1, 1)..Date.new(2013, 12, 31),
    ]
  end

  it "normalizes start and end date for compatibility with other systems" do
    Sie::FinancialYears.between(
      Date.new(2011, 9, 15),
      Date.new(2011, 10, 10),
      start_month: 1,
    ).should == [
      Date.new(2011, 1, 1)..Date.new(2011, 12, 31),
    ]
  end

  it "uses the start month" do
    Sie::FinancialYears.between(
      Date.new(2011, 9, 1),
      Date.new(2014, 1, 31),
      start_month: 5,
    ).should == [
      Date.new(2011, 5, 1)..Date.new(2012, 4, 30),
      Date.new(2012, 5, 1)..Date.new(2013, 4, 30),
      Date.new(2013, 5, 1)..Date.new(2014, 4, 30),
      Date.new(2014, 5, 1)..Date.new(2015, 4, 30),
    ]
  end
end
