class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words do |t|
      t.string :word
      t.string :explanation
      t.timestamp :show_at
      t.string :status, :default => 'bad'
      t.integer :deck_id
      t.timestamps
    end
  end

  def self.down
    drop_table :words
  end
end
