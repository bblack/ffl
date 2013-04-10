class AddMadeByRedbuttonToRfaDecision < ActiveRecord::Migration
  def self.up
    add_column :rfa_decisions, :made_by_redbutton, :boolean
  end

  def self.down
    remove_column :rfa_decisions, :made_by_redbutton
  end
end
