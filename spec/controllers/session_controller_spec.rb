require 'spec_helper'

describe SessionController do
  before(:each) do
    @valid_user_attributes = {
            'login' => 'mylogin',
            'password' => 'mypassword'
    }
  end

  it "should return the register view on every get request" do
    user = mock_model(User)
    User.should_receive(:new).and_return(user)

    get 'register_user'
    response.should render_template('session/register_user')
  end
  
  it "should register a new user" do
    user = mock_model(User)
    user.should_receive(:save).and_return(true)
    User.should_receive(:new).with(@valid_user_attributes).and_return(user)

    post 'register_user', :user => @valid_user_attributes
    flash[:message].should == 'You are successfully registered'
    session[:user_id].should == user.id 
    response.should redirect_to(:controller => 'decks', :action => 'list')
  end

  it "should return the register view if user saving caused some errors" do
    user = mock_model(User)
    user.should_receive(:save).and_return(false)
    User.should_receive(:new).and_return(user)

    post 'register_user'
    response.should render_template('session/register_user')
  end

  it "should return the login view on every get request" do
    get 'login'
    response.should render_template('session/login')
  end

  it "should login a user if his login/password pair is valid" do
    user = mock_model(User)
    User.should_receive(:find_by_login_and_password).with('mylogin', 'mypassword').and_return(user)

    post 'login', @valid_user_attributes
    session[:user_id].should == user.id 
    response.should redirect_to(:controller => 'decks', :action => 'list')
  end

  it "should redirect user to the url saved in session" do
    user = mock_model(User)
    User.should_receive(:find_by_login_and_password).with('mylogin', 'mypassword').and_return(user)

    session[:return_to] = '/myurl'
    post 'login', @valid_user_attributes
    session[:user_id].should == user.id
    response.should redirect_to('myurl')
  end

  it "should return the login page with the error if his login/password pair is invalid" do
    User.should_receive(:find_by_login_and_password).and_return(nil)
    post 'login'
    flash[:error].should == 'The login/password pair is invalid'
    response.should render_template('session/login')
  end

  it "should logout user" do
    session[:user_id] = 1
    get 'logout'
    session[:user_id].should == nil
    response.should redirect_to('/')
  end
end
