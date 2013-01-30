class CreateEspnRosterSpots < ActiveRecord::Migration
  def self.up
    create_table :espn_roster_spots do |t|
      t.integer :espn_player_id
      t.integer :team_id

      t.timestamps
    end
    add_column :teams, :espn_roster_last_updated, :datetime
  end

  def self.down
    remove_column :teams, :espn_roster_last_updated
    drop_table :espn_roster_spots
  end
end
