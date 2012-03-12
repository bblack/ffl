class AddNixedAtToContracts < ActiveRecord::Migration
  def self.up
    add_column :contracts, :nixed_at, :datetime
  end

  def self.down
    remove_column :contracts, :nixed_at
  end
end
