class AddLeagueIdToMove2s < ActiveRecord::Migration
  def self.up
    add_column :move2s, :league_id, :integer
  end

  def self.down
    remove_column :move2s, :league_id
  end
end
