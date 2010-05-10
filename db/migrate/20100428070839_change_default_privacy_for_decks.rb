class ChangeDefaultPrivacyForDecks < ActiveRecord::Migration
  def self.up
    change_column_default :decks, :is_private, true
  end

  def self.down
  end
end
