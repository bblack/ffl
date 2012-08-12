class CreateDraftPickTransactions < ActiveRecord::Migration
  def self.up
    create_table :draft_pick_transactions do |t|
      t.integer :league_id
      t.integer :draft_id
      t.integer :from_team_id
      t.integer :to_team_id
      t.integer :orig_team_id
      t.integer :round

      t.timestamps
    end
  end

  def self.down
    drop_table :draft_pick_transactions
  end
end
