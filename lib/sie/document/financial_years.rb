require "active_support/time"

class Sie::Document
  class FinancialYears
    method_object :between,
      :start_month, :from_date, :to_date

    def between
      from_date.year.upto(to_date.year).map { |year|
        financial_year = FinancialYear.new(year, start_month)
        financial_year_date_range = financial_year.date_range
        financial_year_date_range unless out_of_year_range(financial_year_date_range)
      }.compact
    end

    private

    def out_of_year_range(range)
      range.last.year > to_date.year
    end
  end

  class FinancialYear
    pattr_initialize :year, :start_month

    def date_range
      (start_of_year.beginning_of_month..end_of_year.end_of_month)
    end

    private

    def start_of_year
      start_of_year = Date.new(year, start_month, 1)
    end

    def end_of_year
      a_year_later = start_of_year >> 11
      Date.new(a_year_later.year, a_year_later.month, -1)
    end
  end
end
