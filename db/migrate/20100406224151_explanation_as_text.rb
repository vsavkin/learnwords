class ExplanationAsText < ActiveRecord::Migration
  def self.up
    change_column :words, :explanation, :text
  end

  def self.down
  end
end
