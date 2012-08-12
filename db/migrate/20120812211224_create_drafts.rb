class CreateDrafts < ActiveRecord::Migration
  def self.up
    create_table :drafts do |t|
      t.string :name
      t.string :type
      t.string :state
      t.integer :current_round
      t.integer :current_pick_in_round

      t.timestamps
    end
  end

  def self.down
    drop_table :drafts
  end
end
