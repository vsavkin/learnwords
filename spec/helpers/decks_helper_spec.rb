require 'spec_helper'

describe DecksHelper do

  it "should show repeat right now" do
    helper.repeat_date_output(Time.now.utc - 1).should == "repeat right now"
  end

  it "should show repeat in complex format" do
    helper.repeat_date_output(Time.now.utc + 1.hour).should == "repeat in about 1 hour"
  end
end
