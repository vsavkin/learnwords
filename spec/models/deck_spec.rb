require 'spec_helper'

describe Deck do
  before(:each) do
    @valid_attributes = {
      name: 'my deck'  
    }

    @word_valid_attributes = {
      word: 'word', explanation: 'word', show_at: Time.zone.now
    }
  end

  it "should create a new instance given valid attributes" do
    deck = Deck.create!(@valid_attributes)
    deck.is_private.should == false
    deck.is_active.should == true
  end

  it "shouldn't save a deck with empty deck" do
    deck = Deck.create(@valid_attributes.merge(name: ''))
    deck.should have(1).error_on(:name)
  end

  it "should add new words to a deck" do
    deck = Deck.create(@valid_attributes)
    deck.words.create!(@word_valid_attributes)
    deck.words.size.should == 1
  end

  it "should remove words from a deck" do
    deck = Deck.create(@valid_attributes)
    w = deck.words.create!(@word_valid_attributes)
    w.destroy
    deck.words.size.should == 0
  end

  it "should move words from one deck to another one" do
    deck1 = Deck.create(@valid_attributes.merge(name: 'aaa'))
    deck2 = Deck.create(@valid_attributes.merge(name: 'bbb'))
    w = deck1.words.create!(@word_valid_attributes)
    deck1.move_word_to(w, deck2)

    deck1.words.size.should == 0
    deck2.words.size.should == 1
  end

  it 'should return similar words from deck' do
    deck = Deck.create(@valid_attributes)
    deck.words.create(@word_valid_attributes.merge(word: 'gogo to'))
    deck.words.create(@word_valid_attributes.merge(word: 'to gogo'))
    deck.words.create(@word_valid_attributes.merge(word: 'booms'))
    
    words = deck.similar_words('gogo to')
    words.size.should == 2

    words = deck.similar_words('booms')
    words.size.should == 1

    words = deck.similar_words('crap')
    words.size.should == 0
  end

  it "should return unlearnt words with show_at < now" do
    deck = Deck.create(@valid_attributes)
    deck.words.create(@word_valid_attributes)

    words = deck.words.show_by_now
    words.size.should == 1
  end

  it "should return a random word from the not learnt words with show_at < now" do
    deck = Deck.create(@valid_attributes)
    word_in_future = deck.words.create(@word_valid_attributes.merge(show_at: Time.zone.now + 1.day))
    learnt_word = deck.words.create(@word_valid_attributes.merge(show_at: Time.zone.now - 1.day, status: 'learnt'))
    word_that_should_be_shown = deck.words.create(@word_valid_attributes)
    deck.random_word.should == word_that_should_be_shown
  end

  it "should return nil if all words are learnt" do
    deck = Deck.create(@valid_attributes)
    word_in_future = deck.words.create(@word_valid_attributes.merge(show_at: Time.zone.now + 1.day))
    learnt_word = deck.words.create(@word_valid_attributes.merge(show_at: Time.zone.now - 1.day, status: 'learnt'))
    deck.random_word.should == nil
  end
end
