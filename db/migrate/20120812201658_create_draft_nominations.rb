class CreateDraftNominations < ActiveRecord::Migration
  def self.up
    create_table :draft_nominations do |t|
      t.integer :round
      t.integer :pick_in_round
      t.integer :team_id
      t.integer :player_id

      t.timestamps
    end
  end

  def self.down
    drop_table :draft_nominations
  end
end
