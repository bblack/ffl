class CreateMove2s < ActiveRecord::Migration
  def self.up
    create_table :move2s do |t|
      t.integer :player_id
      t.integer :old_team_id
      t.string :type
      t.integer :new_team_id
      t.integer :new_pv
      t.text :comment
      t.integer :final_year
      t.integer :move2_group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :move2s
  end
end
