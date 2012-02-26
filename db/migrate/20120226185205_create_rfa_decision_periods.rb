class CreateRfaDecisionPeriods < ActiveRecord::Migration
  def self.up
    create_table :rfa_decision_periods do |t|
      t.integer :rfa_period_id
      t.datetime :open_date
      t.datetime :close_date

      t.timestamps
    end
  end

  def self.down
    drop_table :rfa_decision_periods
  end
end
