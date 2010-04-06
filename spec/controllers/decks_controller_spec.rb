require 'spec_helper'

describe DecksController do

  before(:each) do
    @user = mock_model(User)
    session[:user_id] = @user.id

    @decks = [mock_model(Deck), mock_model(Deck)]

    User.stub(:find_by_id).with(@user.id).and_return(@user)
    @user.stub(:decks).and_return(@decks)

    @valid_deck_attributes = {'name' => 'name', 'is_private' => true}
  end

  it "should show the list of decks for the logged user" do
    get 'list'
    assigns[:decks].should == @decks
    response.should render_template('decks/list')
  end

  it "should redirect a user to the login page is he is not logged in" do
    session[:user_id] = nil
    get 'list'
    response.should redirect_to(:controller => 'session', :action => 'login')
  end

  it "should create a new deck for the logged user" do
    deck = mock_model(Deck)
    deck.should_receive(:save).and_return(true)
    @user.should_receive(:create_deck).with(@valid_deck_attributes).and_return(deck)

    post 'create', :deck => @valid_deck_attributes
    response.should redirect_to(:controller => 'decks', :action => 'show', :id => deck.id)
  end

  it "should show the error message if the deck attributes are not valid" do
    deck = mock_model(Deck)
    deck.should_receive(:save).and_return(false)
    @user.should_receive(:create_deck).and_return(deck)

    post 'create', :deck => @valid_deck_attributes
    response.should render_template('decks/list')
  end

  it "should show a deck" do
    deck = mock_model(Deck)
    @user.should_receive(:find_deck).with(deck.id).and_return(deck)
    get 'show', :id => deck.id

    response.should render_template('decks/show')
    assigns[:deck].should == deck
  end

  it "should show a deck list with error message if there is no such deck" do
    @user.should_receive(:find_deck).with(100).and_return(nil)
    get 'show', :id => 100

    response.should redirect_to(:controller => 'main', :action => 'index')
    flash[:error].should == 'There is no deck with such ID'
  end

  it "should be able to edit user's deck" do
    deck = mock_model(Deck)
    deck.should_receive(:update_attributes).with(@valid_deck_attributes).and_return(true)
    @user.should_receive(:find_deck).with(deck.id).and_return(deck)

    post 'edit', :id => deck.id, :deck => @valid_deck_attributes
    response.should render_template('decks/show')
  end

  it "should be able to delete user's deck" do
    deck = mock_model(Deck)
    deck.stub(:name).and_return('name')
    @user.should_receive(:find_deck).with(deck.id).and_return(deck)
    @user.should_receive(:delete_deck).with(deck)

    post 'delete', :id => deck.id
    flash[:message].should == "Your deck 'name' is successfully deleted"
    response.should redirect_to(:controller => 'decks', :action => 'list')
  end

end
