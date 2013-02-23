class CreateEspnStats < ActiveRecord::Migration
  def self.up
    create_table :espn_stats do |t|
      t.integer :player_id
      t.integer :league_id
      t.integer :week
      t.integer :season
      t.string :stats
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :espn_stats
  end
end
