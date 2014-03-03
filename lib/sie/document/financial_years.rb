require "active_support/core_ext/time"
require "active_support/core_ext/date"

class Sie::Document
  class FinancialYears
    def self.between(start_month, from_date, to_date)
      result = []

      from_date.upto(to_date) do |date|
        next if result.any? { |r| r.cover?(date) }

        start_of_year = Date.new(date.year, start_month, 1)
        start_of_year = start_of_year <= date ? start_of_year : (start_of_year << 12)

        a_year_later = start_of_year >> 11
        end_of_year = Date.new(a_year_later.year, a_year_later.month, -1)

        first_date = [start_of_year, from_date].max
        last_date = [end_of_year, to_date].min

        result << (first_date.beginning_of_month..last_date.end_of_month)
      end

      result
    end
  end
end
