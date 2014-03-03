require "active_support/core_ext/time"
require "active_support/core_ext/date"

class Sie::Document
  class FinancialYears
    method_object :between,
      :start_month, :from_date, :to_date

    def between
      from_date.upto(to_date).map { |date|
        financial_year = FinancialYear.new(date, start_month)
        financial_year.date_range(from_date, to_date)
      }.uniq
    end
  end

  class FinancialYear
    pattr_initialize :date, :start_month

    def date_range(from_date, to_date)
      first_date = [ start_of_year, from_date ].max
      last_date = [ end_of_year, to_date ].min
      (first_date.beginning_of_month..last_date.end_of_month)
    end

    private

    def start_of_year
      start_of_year = Date.new(date.year, start_month, 1)

      if start_of_year <= date
        start_of_year
      else
        start_of_year << 12
      end
    end

    def end_of_year
      a_year_later = start_of_year >> 11
      Date.new(a_year_later.year, a_year_later.month, -1)
    end
  end
end
