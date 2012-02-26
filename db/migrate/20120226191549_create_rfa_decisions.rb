class CreateRfaDecisions < ActiveRecord::Migration
  def self.up
    create_table :rfa_decisions do |t|
      t.integer :rfa_decision_period_id
      t.integer :player_id
      t.integer :team_id
      t.boolean :keep

      t.timestamps
    end
  end

  def self.down
    drop_table :rfa_decisions
  end
end
