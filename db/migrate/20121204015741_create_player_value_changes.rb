class CreatePlayerValueChanges < ActiveRecord::Migration
  def self.up
    create_table :player_value_changes do |t|
      t.integer :player_id
      t.integer :new_value
      t.integer :first_year
      t.integer :last_year
      t.integer :team_id
      t.integer :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :player_value_changes
  end
end
