class CreateDecks < ActiveRecord::Migration
  def self.up
    create_table :decks do |t|
      t.string :name
      t.boolean :is_private, :default => false
      t.boolean :is_active, :default => true
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :decks
  end
end
