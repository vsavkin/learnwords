require 'spec_helper'

describe ApplicationHelper do
  it "should generate valid html for flash messages" do
    helper.should_receive(:render).with(
      :partial => 'partials/flash',
      :locals => {:message_type => :error, :message => 'error message'}).and_return('message1')

    helper.should_receive(:render).with(
      :partial => 'partials/flash',
      :locals => {:message_type => :message, :message => 'regular message'}).and_return('message2')

    flash[:error] = 'error message'
    flash[:message] = 'regular message'
    helper.flash_messages.should == 'message1message2'
  end
  
  it "should wrap lines with examples" do
    formatted = helper.format_explanation('', "one\n+two")
    formatted.should == "one<br><span class='wordExample'>+two</span>"
  end

  it "should wrap special sequences" do
    formatted = helper.format_explanation('', "[countable,important]one")
    formatted.should == "<span class='wordNote'>[countable,important]</span>one"
  end

  it "should show only first 12 lines" do
    formatted = helper.format_explanation('', (1..13).to_a.join("\n"))
    formatted.should == (1..12).to_a.join("<br>")
  end  
end