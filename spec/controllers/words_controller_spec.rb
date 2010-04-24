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
    response.should render_template('words/word')
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
    response.should render_template('words/word')
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
    response.should render_template('words/word')
  end

  it "should show the error message if word doesn't belong to the current user" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(false)

    get 'delete', :id => @word.id

    flash[:error].should == 'There is no such word'
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should delete the selected word" do
    deck = mock_model(Deck)
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)
    @word.stub!(:deck).and_return(deck)
    @word.should_receive(:destroy)

    get 'delete', :id => @word.id

    response.should redirect_to(controller: 'decks', action: 'show', id: @word.deck.id)
  end

  it "should retrieve word description" do
    controller.should_receive(:description).with('dog').and_return('text')
    get 'retrieve_word_description', str: 'dog'
    response.should be_success
    response.should have_text('text')
  end

  it "should return error code if it couldn't retrive the word" do
    controller.should_receive(:description).with('dog').and_raise(Exception)
    get 'retrieve_word_description', str: 'dog'
    response.should_not be_success
  end

  it "should return whether the word is important or not" do
    controller.should_receive(:important?).with('dog').and_return(true)
    get 'check_word_importance', str: 'dog'
    response.should be_success
  end

  it "should return similar words in the same deck" do
    deck = mock_model(Deck)
    Deck.should_receive(:find_by_id).with(deck.id).and_return(deck)
    deck.should_receive(:similar_words).with('dog').and_return(['a dog', 'the dog'])

    get 'find_similar_words', str: 'dog', deck_id: deck.id
    JSON.parse(response.body).should == ['a dog', 'the dog']
  end

  it "should return empty array if there are no similar words in the same deck" do
    deck = mock_model(Deck)
    Deck.should_receive(:find_by_id).with(deck.id).and_return(deck)
    deck.should_receive(:similar_words).with('dog').and_return([])

    get 'find_similar_words', str: 'dog', deck_id: deck.id
    JSON.parse(response.body).should == []
  end
end
