class AddSeasonToLeague < ActiveRecord::Migration
  def self.up
    add_column :leagues, :season, :integer
  end

  def self.down
    remove_column :leagues, :season
  end
end
