class AddCompletedOnToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :completed_on, :datetime
  end

  def self.down
    remove_column :transactions, :completed_on
  end
end
