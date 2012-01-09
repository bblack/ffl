class CreateRfaPeriods < ActiveRecord::Migration
  def self.up
    create_table :rfa_periods do |t|
      t.integer :final_year
      t.datetime :open_date
      t.datetime :close_date

      t.timestamps
    end
  end

  def self.down
    drop_table :rfa_periods
  end
end
