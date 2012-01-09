class AddOwnerIdToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :owner_id, :integer
  end

  def self.down
    remove_column :teams, :owner_id
  end
end
