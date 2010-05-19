require 'spec_helper'

describe LearnHelper do

  it "should wrap lines with examples" do
    formatted = helper.format_explanation('', "one\n+two")
    formatted.should == "one<br><span class='wordExample'>+two</span>"
  end

  it "should wrap special sequences" do
    formatted = helper.format_explanation('', "[countable,important]one")
    formatted.should == "<span class='wordNote'>[countable,important]</span>one"
  end

  it "should wrap special words" do
    formatted = helper.format_explanation('', "this is a noun or a verb but nounorverb")
    formatted.should == "this is a<span class='wordNote'> noun </span>or a<span class='wordNote'> verb </span>but nounorverb"
  end

  it "should show only first 12 lines" do
    formatted = helper.format_explanation('', (1..13).to_a.join("\n"))
    formatted.should == (1..12).to_a.join("<br>")
  end

end
