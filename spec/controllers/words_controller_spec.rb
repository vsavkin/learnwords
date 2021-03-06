require 'spec_helper'

describe WordsController do
  include MockHelper

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

    get 'delete', id: @word.id

    flash[:error].should == 'There is no such word'
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should delete the selected word" do
    deck = mock_model(Deck)
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)
    @word.stub!(:deck).and_return(deck)
    @word.should_receive(:destroy)

    get 'delete', id: @word.id

    response.should redirect_to(controller: 'decks', action: 'show', id: @word.deck.id)
  end

  it "should show the error message if one of the words doesn't belong to the current user" do
    word1, word2 = mock_model(Word), mock_model(Word)
    Word.should_receive(:find_by_id).with(word1.id).and_return(word1)
    Word.should_receive(:find_by_id).with(word2.id).and_return(word2)
    @user.should_receive(:has_word).with(word1).and_return(true)
    @user.should_receive(:has_word).with(word2).and_return(false)

    get 'delete_all', id: [word1.id, word2.id]

    flash[:error].should_not be_nil
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should redirect to the main page if the list of ids for deleting is empty" do
    get 'delete_all', id: []
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should delete all the selected words" do
    deck = mock_model(Deck)
    word1, word2 = mock_model(Word), mock_model(Word)
    word1.stub!(:deck).and_return(deck)
    word2.stub!(:deck).and_return(deck)
    Word.should_receive(:find_by_id).with(word1.id).and_return(word1)
    Word.should_receive(:find_by_id).with(word2.id).and_return(word2)
    @user.should_receive(:has_word).with(word1).and_return(true)
    @user.should_receive(:has_word).with(word2).and_return(true)
    word1.should_receive(:destroy)
    word2.should_receive(:destroy)

    get 'delete_all', id: [word1.id, word2.id]

    response.should redirect_to(controller: 'decks', action: 'show', id: word1.deck.id)
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

  it "should return error code if a word description is empty" do
    controller.should_receive(:description).with('dog').and_return('')
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
    word = mock_model(Word)
    word.stub!(:word).and_return('booms')
    deck.should_receive(:similar_words).with('dog').and_return([word])

    get 'find_similar_words', str: 'dog', deck_id: deck.id
    JSON.parse(response.body).should == [word.word]
  end

  it "should return empty array if there are no similar words in the same deck" do
    deck = mock_model(Deck)
    Deck.should_receive(:find_by_id).with(deck.id).and_return(deck)
    deck.should_receive(:similar_words).with('dog').and_return([])

    get 'find_similar_words', str: 'dog', deck_id: deck.id
    JSON.parse(response.body).should == []
  end

  it "should move all the words from one deck into another" do
    src_deck, dest_deck = mock_model(Deck), mock_model(Deck)
    @user.should_receive(:find_deck).with(src_deck.id).and_return(src_deck)
    @user.should_receive(:find_deck).with(dest_deck.id).and_return(dest_deck)
    word1, word2 = model_with_finder(Word), model_with_finder(Word)

    src_deck.should_receive(:move_word_to).with(word1, dest_deck)
    src_deck.should_receive(:move_word_to).with(word2, dest_deck)

    get 'move_all', id: [word1.id, word2.id], src_deck_id: src_deck.id, dest_deck_id: dest_deck.id
    
    flash[:error].should be_nil
  end

  it "should show an error message if the src deck doens't belong to a current user" do
    src_deck, dest_deck = mock_model(Deck), mock_model(Deck)
    @user.should_receive(:find_deck).with(src_deck.id).and_return(nil)
    @user.should_receive(:find_deck).with(dest_deck.id).and_return(dest_deck)

    get 'move_all', id: [], src_deck_id: src_deck.id, dest_deck_id: dest_deck.id

    flash[:error].should_not be_nil
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should show an error message if the dest deck doens't belong to a current user" do
    src_deck, dest_deck = mock_model(Deck), mock_model(Deck)
    @user.should_receive(:find_deck).with(src_deck.id).and_return(src_deck)
    @user.should_receive(:find_deck).with(dest_deck.id).and_return(nil)

    get 'move_all', id: [], src_deck_id: src_deck.id, dest_deck_id: dest_deck.id

    flash[:error].should_not be_nil
    response.should redirect_to(controller: 'main', action: 'index')
  end
end
