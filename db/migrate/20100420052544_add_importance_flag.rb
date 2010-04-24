class AddImportanceFlag < ActiveRecord::Migration
  def self.up
    add_column :words, :is_important, :boolean, :default => false    
  end

  def self.down
  end
end
