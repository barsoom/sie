require "attr_extras"
require "sie/document/voucher_series"
require "sie/document/renderer"
require "active_support/core_ext/module/delegation"
require 'zlib'

module Sie
  class Document
    # Because some accounting software have limits
    #  - Fortnox should handle 200
    #  - Visma etc -> 100
    DESCRIPTION_LENGTH_MAX = 100

    pattr_initialize :data_source, [ exclude_balance_rows: false ]

    def render
      add_header
      add_financial_years
      add_accounts
      add_dimensions
      add_balances
      add_vouchers
      add_footer

      result = renderer.render
      result.include?('KSUMMA') ? add_ksumma(result) : result
    end

    private

    delegate :add_line, :add_array,
      to: :renderer

    def add_ksumma(result)
      result.gsub('KSUMMAVALUE', ksumma(result).to_s)
    end

    def ksumma(result)
      raw_file = result.scan(/(?:(?<=\#KSUMMA\n)|(?!^)\G)[,{}()"\s]*\K[^,{}()"\s](?=.*\#KSUMMA)/m)
      hash_ksumma(raw_file.reduce(:+))
    end

    def hash_ksumma(checksum)
      Zlib::crc32(checksum)
    end

    delegate :program, :program_version, :generated_on, :company_name,
      :accounts, :balance_account_numbers, :closing_account_numbers,
      :balance_before, :each_voucher, :dimensions,
      to: :data_source

    def add_header
      add_line("FLAGGA", 0)
      add_line("KSUMMA")
      add_line("PROGRAM", program, program_version)
      add_line("FORMAT", "PC8")
      add_line("GEN", generated_on)
      add_line("SIETYP", 4)
      add_line("FNAMN", company_name)
    end

    def add_footer
      add_line("KSUMMA KSUMMAVALUE")
    end

    def add_financial_years
      financial_years.each_with_index do |date_range, index|
        add_line("RAR", -index, date_range.begin, date_range.end)
      end
    end

    def add_accounts
      accounts.each do |account|
        number      = account.fetch(:number)
        description = account.fetch(:description).slice(0, DESCRIPTION_LENGTH_MAX)

        add_line("KONTO", number, description)
      end
    end

    def add_balances
      return if exclude_balance_rows

      financial_years.each_with_index do |date_range, index|
        add_balance_rows("IB", -index, balance_account_numbers, date_range.begin)
        add_balance_rows("UB", -index, balance_account_numbers, date_range.end)
        add_balance_rows("RES", -index, closing_account_numbers, date_range.end)
      end
    end

    def add_balance_rows(label, year_index, account_numbers, date, &block)
      account_numbers.each do |account_number|
        balance = balance_before(account_number, date)

        # Accounts with no balance should not be in the SIE-file.
        # See paragraph 5.17 in the SIE file format guide (Rev. 4B).
        next unless balance

        add_line(label, year_index, account_number, balance)
      end
    end

    def add_dimensions
      dimensions.each do |dimension|
        dimension_number = dimension.fetch(:number)
        dimension_description = dimension.fetch(:description)
        add_line("DIM", dimension_number, dimension_description)

        dimension.fetch(:objects).each do |object|
          object_number = object.fetch(:number)
          object_description = object.fetch(:description)
          add_line("OBJEKT", dimension_number, object_number, object_description)
        end
      end
    end

    def add_vouchers
      each_voucher do |voucher|
        add_voucher(voucher)
      end
    end

    def add_voucher(opts)
      number         = opts.fetch(:number)
      booked_on      = opts.fetch(:booked_on)
      description    = opts.fetch(:description).slice(0, DESCRIPTION_LENGTH_MAX)
      voucher_lines  = opts.fetch(:voucher_lines)
      voucher_series = opts.fetch(:series) {
        creditor = opts.fetch(:creditor)
        type = opts.fetch(:type)
        VoucherSeries.for(creditor, type)
      }

      add_line("VER", voucher_series, number, booked_on, description)

      add_array do
        voucher_lines.each do |line|
          account_number = line.fetch(:account_number)
          amount         = line.fetch(:amount)
          booked_on      = line.fetch(:booked_on)
          dimensions     = line.fetch(:dimensions, {}).flatten
          # Some SIE-importers (fortnox) cannot handle descriptions longer than 200 characters,
          # but the specification has no limit.
          description    = line.fetch(:description).slice(0, DESCRIPTION_LENGTH_MAX)

          add_line("TRANS", account_number, dimensions, amount, booked_on, description)

          # Some consumers of SIE cannot handle single voucher lines (fortnox), so add another empty one to make
          # it balance. The spec just requires the sum of lines to be 0, so single lines with zero amount would conform,
          # but break for these implementations.
          if voucher_lines.size < 2 && amount.zero?
            add_line("TRANS", account_number, dimensions, amount, booked_on, description)
          end
        end
      end
    end

    def renderer
      @renderer ||= Renderer.new
    end

    def financial_years
      data_source.financial_years.sort_by { |date_range| date_range.first }.reverse
    end
  end
end
