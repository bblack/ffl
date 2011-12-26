class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.integer :league_id
      t.integer :team_id
      t.integer :player_id
      t.integer :first_year
      t.integer :length
      t.integer :value

      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
