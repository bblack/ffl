class CreateRfaBids < ActiveRecord::Migration
  def self.up
    create_table :rfa_bids do |t|
      t.integer :rfa_period_id
      t.integer :team_id
      t.integer :player_id

      t.timestamps
    end
  end

  def self.down
    drop_table :rfa_bids
  end
end
