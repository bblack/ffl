class AddNixMessageToContracts < ActiveRecord::Migration
  def self.up
    add_column :contracts, :nix_message, :string
  end

  def self.down
    remove_column :contracts, :nix_message
  end
end
