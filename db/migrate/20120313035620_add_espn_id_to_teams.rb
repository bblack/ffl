class AddEspnIdToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :espn_id, :string
  end

  def self.down
    remove_column :teams, :espn_id
  end
end
