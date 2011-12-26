class RemoveLeagueIdFromContract < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :league_id
  end

  def self.down
    add_column :contracts, :league_id, :integer
  end
end
