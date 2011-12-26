class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.integer :mfl_id
      t.string :first_name
      t.string :last_name
      t.string :nfl_team
      t.string :position

      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
