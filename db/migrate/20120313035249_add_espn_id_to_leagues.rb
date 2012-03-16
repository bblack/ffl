class AddEspnIdToLeagues < ActiveRecord::Migration
  def self.up
    add_column :leagues, :espn_id, :string
  end

  def self.down
    remove_column :leagues, :espn_id
  end
end
