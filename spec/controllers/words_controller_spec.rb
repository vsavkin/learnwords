require 'spec_helper'

describe WordsController do

  before(:each) do
    @user = mock_model(User)
    session[:user_id] = @user.id
    @word = mock_model(Word)

    User.should_receive(:find_by_id).with(@user.id).and_return(@user)

    @valid_word_attributes = {
      'word' => 'word', 'explanation' => 'blamblam', 'show_at' => Time.zone.now
    }
  end

  it "should show the form of editing if the word exists" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)

    get 'edit', :id => @word.id

    assigns[:word].should == @word
    response.should render_template('words/edit') 
  end

  it "should show the error message if the word doesn't exist" do
    Word.should_receive(:find_by_id).and_return(nil)

    get 'edit', :id => 1

    assigns[:word].should == nil
    flash[:error].should == 'There is no such word'
    response.should render_template('words/close') 
  end

  it "should show the error message if the deck isn't yours" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(false)

    get 'edit', :id => @word.id

    flash[:error].should == 'There is no such word'
    response.should render_template('words/close')
  end

  it "should save the word attributes" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)
    @word.should_receive(:update_attributes).with(@valid_word_attributes).and_return(true)

    post 'edit', :id => @word.id, :word => @valid_word_attributes

    assigns[:word].should == @word
    response.should render_template('words/close')
  end

  it "should show empty form for a new word" do
    get 'create'
    response.should render_template('words/create')
  end

  it "should create a new word" do
    deck = mock_model(Deck)
    Deck.should_receive(:find_by_id).with(1).and_return(deck)
    deck.should_receive(:create_word).with(@valid_word_attributes).and_return(@word)
    @word.should_receive(:show_at=)
    @word.should_receive(:save).and_return(true)

    post 'create', :word => @valid_word_attributes, :deck_id => 1

    assigns[:word].should == @word
    response.should render_template('words/close')
  end

  it "should show create page with error messages" do
    deck = mock_model(Deck)
    Deck.should_receive(:find_by_id).with(1).and_return(deck)
    deck.should_receive(:create_word).with(@valid_word_attributes).and_return(@word)
    @word.should_receive(:show_at=)
    @word.should_receive(:save).and_return(false)

    post 'create', :word => @valid_word_attributes, :deck_id => 1

    assigns[:word].should == @word
    response.should render_template('words/create')
  end
end
