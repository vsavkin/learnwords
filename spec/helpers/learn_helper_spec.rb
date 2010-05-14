require 'spec_helper'

describe LearnHelper do

  it "should wrap lines with examples" do
    formatted = helper.format_explanation('', "one\n+two")
    formatted.should == "one<br><span class='wordExample'>+two</span>"
  end

  it "should wrap special sequences" do
    formatted = helper.format_explanation('', "[countable]one")
    formatted.should == "<span class='wordType'>[countable]</span>one"
  end

  it "should show only first 12 lines" do
    formatted = helper.format_explanation('', (1..13).to_a.join("\n"))
    formatted.should == (1..12).to_a.join("<br>")
  end

end
