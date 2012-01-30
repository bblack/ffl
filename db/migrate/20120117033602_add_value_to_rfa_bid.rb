class AddValueToRfaBid < ActiveRecord::Migration
  def self.up
    add_column :rfa_bids, :value, :integer
  end

  def self.down
    remove_column :rfa_bids, :value
  end
end
