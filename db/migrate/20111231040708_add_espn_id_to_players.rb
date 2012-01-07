class AddEspnIdToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :espn_id, :integer
  end

  def self.down
    remove_column :players, :espn_id
  end
end
