class Sie::Document::Renderer
  EMPTY_ARRAY = :empty_array

  def initialize
    @io = StringIO.new
    @io.set_encoding(Encoding::CP437)
  end

  def add_line(label, *values)
    append ["##{ label }", *format_values(values)].join(" ")
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
    io.puts(text)
  end

  def format_values(values)
    values.map { |value| format_value(value) }
  end

  def format_value(value)
    case value
    when Date
      value.strftime("%Y%m%d")
    when EMPTY_ARRAY
      "{}"
    when Numeric
      value.to_s
    else
      '"' + value.to_s.gsub('"', '\"') + '"'
    end
  end
end
