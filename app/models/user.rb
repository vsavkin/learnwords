class User < ActiveRecord::Base
  validates_length_of :password, :minimum => 6
  validates_length_of :login, :in => 1..32
  validates_uniqueness_of :login
  has_many :decks

  def copy(deck)
    raise "Can't copy private decks" if deck.is_private
    raise "Can't copy your own deck" if deck.user == self
    
    new_deck = decks.create(deck.fresh_copy.attributes)
    deck.words.each do |w|
      new_deck.words.create(w.fresh_copy.attributes)
    end
  end

  def create_deck(deck)
    decks.create(deck)
  end

  def find_deck(id)
    decks.find_by_id(id)
  end

  def delete_deck(deck)
    raise "A deck of another user can't be delete" unless deck.user == self 
    deck.destroy
  end

  def has_word(word)
    decks.include? word.deck
  end
end
