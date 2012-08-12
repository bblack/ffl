class AddLeagueIdToDrafts < ActiveRecord::Migration
  def self.up
    add_column :drafts, :league_id, :integer
  end

  def self.down
    remove_column :drafts, :league_id
  end
end
