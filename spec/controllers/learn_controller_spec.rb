require 'spec_helper'

describe LearnController do

  before (:each) do
    @word = mock_model(Word)
    @deck = mock_model(Deck)
    @word.stub(:deck).and_return(@deck)
    
    @user = mock_model(User)
    session[:user_id] = @user.id
    User.stub(:find_by_id).with(@user.id).and_return(@user)
  end

  it "should redirect to the main page if deck is not belong to the logged user" do
    @user.should_receive(:find_deck).and_return(nil)
    get 'show_word', deck_id: @deck.id

    response.should redirect_to(controller: 'main', action: 'index')
    flash[:error].should == 'There is no deck with such ID'
  end

  it "should retrieve a random word and show it" do
    @user.should_receive(:find_deck).with(@deck.id.to_s).and_return(@deck)
    @deck.should_receive(:random_word).and_return(@word)

    get 'show_word', deck_id: @deck.id

    assigns[:deck].should == @deck
    assigns[:word].should == @word
    assigns[:with_answer].should be_nil
    response.should render_template('learn/show')
  end

  it "should show special page if you have repeated all words" do
    @user.should_receive(:find_deck).with(@deck.id.to_s).and_return(@deck)
    @deck.should_receive(:random_word).and_return(nil)

    get 'show_word', deck_id: @deck.id

    assigns[:deck].should == @deck
    assigns[:word].should == nil
    response.should render_template('learn/all_repeated')
  end

  it "should show a word with its explanation" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)

    get 'answer', id: @word.id
    
    assigns[:word].should == @word
    assigns[:with_answer].should be_true
    response.should render_template('learn/show')
  end

  it "should show the error message if the word doesn't belong to the user" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(false)

    get 'answer', id: @word.id

    flash[:error].should == 'There is no word with such ID'
    response.should redirect_to(controller: 'main', action: 'index')
  end

  it "should show a error message of word doesn't belong to a user" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(false)

    post 'update_status', word_id: @word.id

    response.should redirect_to(controller: 'main', action: 'index')
    flash[:error].should == 'There is no word with such ID'
  end

  it "should update the status and show a user another word" do
    Word.should_receive(:find_by_id).with(@word.id.to_s).and_return(@word)
    @user.should_receive(:has_word).with(@word).and_return(true)
    @word.should_receive(:update_status).with('normal')

    post 'update_status', word_id: @word.id, status: 'normal'

    response.should redirect_to(controller: 'learn', action: 'show_word', deck_id: @word.deck.id)
  end
end
