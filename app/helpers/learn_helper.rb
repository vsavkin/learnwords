module LearnHelper
  def format_explanation(word, text)
    text = wrap_word_note_parts(text)
    lines = lines(text)
    lines = wrap_example_lines(lines)
    lines[0...12].join("<br>")
  end

  private
  def wrap_word_note_parts(text)
    text.gsub(/\[\w+\]/) { |e| "<span class='wordNote'>#{e}</span>" }
  end

  def wrap_example_lines(lines)
    lines.collect do |line|
      if line_with_example? line
        "<span class='wordExample'>#{line}</span>"
      else
        line
      end
    end
  end

  def lines(text)
    text.split("\n").collect { |line| line.strip }
  end

  def line_with_example?(line)
    line[0] == '+'
  end
end
