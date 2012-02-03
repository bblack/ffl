class AddSalaryCapToLeagues < ActiveRecord::Migration
  def self.up
    add_column :leagues, :salary_cap, :integer
  end

  def self.down
    remove_column :leagues, :salary_cap
  end
end
