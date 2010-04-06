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

  def similar_words(word)
    res = generate_all_combinations(word).inject([]) do |res, element|
      w = words.find(:all, :conditions => ['word LIKE ?', "%#{element}%"])
      res + w
    end
    res.uniq
  end

  def random_word
    w = words.show_by_now
    return nil if w.empty?
    w[rand(w.size)]
  end

  private
  def generate_all_combinations(word)
    parts = Word.normalize(word).split(' ')
    [word] + parts.find_all{|m| m.size > 3}
  end
end
