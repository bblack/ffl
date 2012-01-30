class AddLeagueIdToRfaPeriod < ActiveRecord::Migration
  def self.up
    add_column :rfa_periods, :league_id, :integer
  end

  def self.down
    remove_column :rfa_periods, :league_id
  end
end
