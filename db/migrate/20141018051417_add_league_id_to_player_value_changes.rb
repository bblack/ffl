class AddLeagueIdToPlayerValueChanges < ActiveRecord::Migration
  def self.up
    add_column :player_value_changes, :league_id, :integer
    remove_column :player_value_changes, :team_id
  end

  def self.down
    add_column :player_value_changes, :team_id, :integer
    remove_column :player_value_changes, :league_id
  end
end
