class AddRedbuttonedToRfaPeriod < ActiveRecord::Migration
  def self.up
    add_column :rfa_periods, :redbuttoned, :boolean
  end

  def self.down
    remove_column :rfa_periods, :redbuttoned
  end
end
