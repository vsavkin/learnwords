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
end