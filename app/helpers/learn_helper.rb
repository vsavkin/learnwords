module LearnHelper
  def format_explanation(word, text)
    text.gsub!(/\[\w+\]/){|e| "<span class='wordType'>#{e}</span>"}

    lines = text.split("\n").collect{|line| line.strip}
    lines = lines.collect do |line|
      if line[0] == '+'
        "<span class='wordExample'>#{line}</span>"
      else
        line  
      end
    end
    lines[0..12].join("<br>")
  end
end
