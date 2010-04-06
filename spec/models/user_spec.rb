
require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {
            :login => 'mylogin',
            :password => 'mypassword'
    }

    @word_valid_attributes = {
      :word => 'word', :explanation => 'word', :show_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    user = User.create!(@valid_attributes)
    user.login.should == 'mylogin'
    user.password.should == 'mypassword'
  end

  it "should reject short passwords" do
    user = User.create(@valid_attributes.merge(:password => 'a'))
    user.should have(1).error_on(:password)
  end

  it "should reject empty logins" do
    user = User.create(@valid_attributes.merge(:login => ''))
    user.should have(1).error_on(:login)
  end

  it "should check the uniquenes of logins" do
    User.create(@valid_attributes.merge(:login => 'aaa'))
    user = User.create(@valid_attributes.merge(:login => 'aaa'))
    user.should have(1).error_on(:login)
  end

  it "should copy a public deck from another user" do
    user1 = User.create(@valid_attributes.merge(:login => 'aaa'))
    user2 = User.create(@valid_attributes.merge(:login => 'bbb'))

    deck = user1.decks.create(:name => 'SuperDeck')
    deck.words.create(:word => 'word', :explanation => 'word', :status => 'normal', :show_at => Time.now + 3.day)

    user2.copy(deck)

    first_word_for(user1).status.should == 'normal'
    (first_word_for(user1).show_at >= Time.now + 3.day - 1.second).should be_true

    first_word_for(user2).status.should == 'bad'
    (first_word_for(user2).show_at < Time.now + 1.day).should be_true
  end

  it "shouldn't copy a private deck from another user" do
    user1 = User.create(@valid_attributes.merge(:login => 'aaa'))
    user2 = User.create(@valid_attributes.merge(:login => 'bbb'))

    deck = user1.decks.create(:name => 'SuperDeck', :is_private => true)
    lambda {user2.copy(deck)}.should raise_error(Exception)
  end

  it 'should be able to create and find decks using sugar methods' do
    user = User.create(@valid_attributes)

    deck = user.create_deck(:name => 'SuperDeck', :is_private => true)
    deck.save.should be_true

    user.find_deck(deck.id).should == deck
    user.find_deck(deck.id + 100).should == nil
  end

  it "should create a deck that are not valid" do
    user = User.create(@valid_attributes)
    deck = user.create_deck(:name => '', :is_private => true)

    deck.save.should be_false
    user.decks(true).should be_empty
  end

  it "should be able to check whether a user has a word or not" do
    user1 = User.create!(@valid_attributes.merge(:login => 'Sam'))
    deck1 = user1.decks.create!(:name => 'SuperDeck')
    word1 = deck1.words.create!(@word_valid_attributes)

    user2 = User.create!(@valid_attributes.merge(:login => 'John'))
    deck2 = user2.decks.create!(:name => 'SuperDeck')
    word2 = deck2.words.create!(@word_valid_attributes)

    user1.has_word(word1).should be_true
    user1.has_word(word2).should be_false
  end

  it "should be able to delete deck" do
    user = User.create!(@valid_attributes)
    deck = user.decks.create!(:name => 'SuperDeck')
    user.decks.size.should == 1

    user.delete_deck(deck)
    user.decks.should be_empty
  end

  it "shouldn't be able to delete a deck of another user" do
    user1 = User.create!(@valid_attributes.merge(:login => 'john'))
    user2 = User.create!(@valid_attributes.merge(:login => 'piter'))
    deck = user1.decks.create!(:name => 'SuperDeck')

    lambda{user2.delete_deck(deck)}.should raise_error(Exception)
  end

  private
  def first_word_for(user)
    user.decks(true)[0].words[0]
  end
end
