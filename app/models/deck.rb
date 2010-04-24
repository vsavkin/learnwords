class Deck < ActiveRecord::Base
  has_many :words
  belongs_to :user
  validates_length_of :name, :minimum => 1

  def create_word(args)
    words.create(args)
  end

  def move_word_to(word, deck)
    word.destroy
    deck.words.create#(word.attributes)
  end

  def fresh_copy
    Deck.new(attributes.merge(:is_active => true))
  end

  def similar_words(str)
    word = OaldParser::WordExtractor.new.extract(str)
    words.find(:all, :conditions => ['word LIKE ?', "%#{word}%"])
  end

  def random_word
    w = words.show_by_now
    return nil if w.empty?
    w[rand(w.size)]
  end
end
