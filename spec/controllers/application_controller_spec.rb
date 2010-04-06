require 'spec_helper'

describe ApplicationController do

  it "should fetch logged user from database" do
    user = mock_model(User)
    User.should_receive(:find_by_id).with(1).and_return(user)
    session[:user_id] = 1
    get 'fetch_logged_in'
    assigns[:current_user].should == user 
  end

  it "should do nothing if you already logged in" do
    User.should_receive(:find_by_id).with(1).and_return('user')
    session[:user_id] = 1

    get 'fetch_logged_in'
    controller.logging_required.should be_true	
  end

  it "should redirect user to the login page" do
    get 'logging_required'
    response.should redirect_to(:controller => 'session', :action => 'login')
    session[:return_to].should == request.request_uri
  end

end
