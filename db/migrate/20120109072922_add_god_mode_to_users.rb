class AddGodModeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :god_mode, :boolean
  end

  def self.down
    remove_column :users, :god_mode
  end
end
