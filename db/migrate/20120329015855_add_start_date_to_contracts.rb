class AddStartDateToContracts < ActiveRecord::Migration
  def self.up
    add_column :contracts, :started_at, :datetime
    add_column :contracts, :started_msg, :text
    Contract.find_each(:batch_size => 100) do |contract|
      contract.started_at = contract.created_at
      contract.started_msg = "start date set to created date by migration"
      contract.save
    end
  end

  def self.down
    remove_column :contracts, :started_msg
    remove_column :contracts, :started_at
  end
end
