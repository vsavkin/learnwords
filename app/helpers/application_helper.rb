module ApplicationHelper
  def flash_messages
    messages = flash.map do |message_type, message|
      render(partial: 'partials/flash',
              locals: {message_type: message_type, message: message}) unless message.blank?
    end
    messages.join('')
  end

  def popup_window(link, title, url)
    link_to_prototype_window link, "uniqwindow",
                             url: url, width: 640, height: 540, className: 'alphacube', recenterAuto: true,
                             draggable: false, resizable: false, title: title,
                             minimizable: false, maximizable: false, effectOptions: {duration: 0.1}
  end
  
  def format_explanation(word, text, lines_count = 12)
    text = wrap_square_braces(text)
    lines = lines(text)
    lines = wrap_example_lines(lines)
    lines[0...lines_count].join("<br>")
  end

  private
  def wrap_square_braces(text)
    text.gsub(/\[[^\]]+\]/) { |e| "<span class='wordNote'>#{e}</span>" }
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
