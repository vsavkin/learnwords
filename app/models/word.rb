class Word < ActiveRecord::Base
  belongs_to :deck
  validates_length_of :word, :minimum => 1
  validates_length_of :explanation, :minimum => 1
  validates_inclusion_of :status, :in => ['bad', 'normal', 'good', 'excellent', 'learnt']

  named_scope :show_by_now, :conditions => ['show_at <= ? AND status != ?', Time.now.utc, 'learnt']
  named_scope :learnt, :conditions => ['status = ?', 'learnt']
  

  def before_save
    self.word = Word.normalize(word)
  end

  def self.normalize(word)
    word.strip.gsub(/[\s]+/, ' ')
  end

  def self.next_statuses
    {
      'bad' =>       {'bad' => 'bad',    'normal' => 'normal', 'good' => 'normal',   'excellent' => 'good'},
      'normal' =>    {'bad' => 'bad',    'normal' => 'good',   'good' => 'good',     'excellent' => 'excellent'},
      'good' =>      {'bad' => 'bad',    'normal' => 'good',   'good' => 'good',     'excellent' => 'excellent'},
      'excellent' => {'bad' => 'normal', 'normal' => 'good',   'good' => 'excellent','excellent' => 'learnt'}
    }
  end

  def self.show_in_days
    {
      'bad' =>       {'bad' => 0, 'normal' => 1, 'good' => 3, 'excellent' => 7},
      'normal' =>    {'bad' => 0, 'normal' => 3, 'good' => 7, 'excellent' => 21},
      'good' =>      {'bad' => 0, 'normal' => 3, 'good' => 7, 'excellent' => 14},
      'excellent' => {'bad' => 0, 'normal' => 1, 'good' => 3, 'excellent' => 0}
    }
  end

  def fresh_copy
    Word.new(attributes.merge(:status => 'bad', :show_at => Time.now))
  end

  def update_status(new_status)
    next_status = Word.next_statuses[status][new_status]
    days = Word.show_in_days[status][new_status]
    update_attributes!(:status => next_status, :show_at => self.show_at + days.day)
  end
end
