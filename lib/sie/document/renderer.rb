require "stringio"

class Sie::Document::Renderer
  ENCODING = Encoding::CP437

  def initialize
    @io = StringIO.new
    @io.set_encoding(ENCODING)
  end

  def add_line(label, *values)
    append [ "##{ label }", *format_values(values) ].join(" ")
  end

  def add_array
    append "{"
    yield
    append "}"
  end

  def render
    io.rewind
    io.read
  end

  attr_private :io

  private

  def append(text)
    io.puts(encoded(text))
  end

  def format_values(values)
    values.map { |value| format_value(value) }
  end

  def encoded(text)
    text.encode(ENCODING, :invalid => :replace, :undef => :replace, :replace => "?")
  end

  def format_value(value)
    case value
    when Date
      value.strftime("%Y%m%d")
    when Array
      subvalues = value.map { |subvalue| format_value(subvalue.to_s) }
      "{#{subvalues.join(' ')}}"
    when Numeric
      value.to_s
    else
      '"' + value.to_s.gsub('"', '\"') + '"'
    end
  end
end
