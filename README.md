# Sie

## Installation

Add this line to your application's Gemfile:

    gem 'sie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sie

## Developing

First time setup:

    script/bootstrap

Running tests:

    rake

Getting the latest code and gems:

    script/refresh

## Generating a SIE file

To generate a SIE document you have to define a class that responds to the methods below. Try it out! Copy and paste this example into a ruby file and run it.

```ruby
require "date"

class YourDataSource
  def program
    "Your app"
  end

  def program_version
    "1.0"
  end

  def generated_on
    Date.today
  end

  def from_date
    Date.today
  end

  def to_date
    Date.today
  end

  def company_name
    "Your company"
  end

  def financial_year_start_month
    1
  end

  def accounts
    [
      number: 1500, description: "Customer ledger"
    ]
  end

  def balance_account_numbers
    [ "1500", "2400" ]
  end

  def closing_account_numbers
    [ "3100" ]
  end

  # Usually calculating the balance before (and on) the specific date requires some
  # database interaction, so the document uses this callback to fetch that data as needed.
  def balance_before(account_number, date)
    # ActiveRecord example: VoucherLine.where('booked_on <= ?', date).where(account_number: account_number).sum(:amount)
    0
  end

  # This method allows you to load voucher data in batches so that you can generate large
  # SIE files without having to keep lots of data in memory at once.
  def each_voucher(&block)
    [
      {
        creditor: false, type: :invoice, number: 1, booked_on: Date.today, description: "Invoice 1",
        voucher_lines: [
          { account_number: "1500", amount: 512.0, booked_on: Date.today, description: "Item 1" },
          { account_number: "3100", amount: -512.0, booked_on: Date.today, description: "Item 1" },
        ]
      }
    ].each(&block)
  end
end

data_source = YourDataSource.new

require "sie"
doc = Sie::Document.new(data_source)
puts doc.render
```

For more info, see the specs.

## Parsing a SIE file

For now, see the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits and license

By [Barsoom](http://barsoom.se) under the MIT license:

>  Copyright (c) 2013 Barsoom AB
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
