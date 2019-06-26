# Sie

[![Build status](https://github.com/barsoom/sie/actions/workflows/ci.yml/badge.svg)](https://github.com/barsoom/sie/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/barsoom/sie.svg)](https://codeclimate.com/github/barsoom/sie)

SIE parser and generator supporting the [format "SIE typ 1-4 – Klassisk SIE"](https://sie.se/format/).

## Installation

Add this line to your application's Gemfile:

    gem 'sie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sie

## Generating a SIE file

To generate a SIE document you define a class that responds to the methods below. Try it out! Copy and paste this example into a ruby file and run it.

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

  def financial_years
    [
      Date.new(2011, 1, 1)..Date.new(2011, 12, 31),
      Date.new(2012, 1, 1)..Date.new(2012, 12, 31),
      Date.new(2013, 1, 1)..Date.new(2013, 12, 31),
    ]
  end

  def company_name
    "Your company"
  end

  def accounts
    [
      { number: 1500, description: "Customer ledger" },
    ]
  end

  def balance_account_numbers
    [ 1500, 2400 ]
  end

  def closing_account_numbers
    [ 3100 ]
  end

  def dimensions
    [
      {
        number: 6,
        description: "Projekt",
        objects: [
          { number: 1, description: "Education" }
        ]
      }
    ]
  end

  # Used to calculate balance before (and on) the given date for an account.
  def balance_before(account_number, date)
    # ActiveRecord example:
    # VoucherLine.where('booked_on <= ?', date).
    # where(account_number: account_number).sum(:amount)

    0
  end

  # Used to load voucher data in batches so that you don't need to load all of
  # it into memory at once.
  def each_voucher(&block)
    [
      {
        # "creditor" and "type" is used to find the series, you can replace
        # that with "series" if the automatic lookup doesn't work for you.
        creditor: false, type: :invoice,

        number: 1, booked_on: Date.today, description: "Invoice 1",
        voucher_lines: [
          {
            account_number: 1500, amount: 512.0,
            booked_on: Date.today, description: "Item 1"
          },
          {
            account_number: 3100, amount: -512.0,
            booked_on: Date.today, description: "Item 1",
            dimensions: { 6 => 1 }
          },
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

You can parse sie data from anything that responds to `each_line` like a file or a string.

```ruby
File.open("path/to/file.se") do |f|
  parser = Sie::Parser.new
  sie_file = parser.parse(f)

  # The company name
  puts sie_file.entries_with_label("fnamn").first.attributes["foretagsnamn"]

  # The first account number
  puts sie_file.entries_with_label("konto").first.attributes["kontonr"]
end
```

By default the parser will raise an error if it encounters unknown entry types. Use the `lenient` option to avoid this:

```ruby
parser = Sie::Parser.new(lenient: true)
```

For more info, see the specs.

## Developing

First time setup:

    script/bootstrap

Running tests:

    bundle exec rake

Getting the latest code and gems:

    script/refresh

## Resources

[SIE format specification rev 4B (Swedish)](https://sie.se/wp-content/uploads/2020/05/SIE_filformat_ver_4B_080930.pdf)

## See also

* [PHP port of this library](https://github.com/neam/php-sie)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Try to be consistent with the local code style. `[ foo ]` not `[foo]`, double quotes not single quotes, small and well named methods, etc.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

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
