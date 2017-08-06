class ChangePvcCommentToText < ActiveRecord::Migration
  def up
    change_column :player_value_changes, :comment, :text
  end

  def down
    change_column :player_value_changes, :comment, :integer
  end
end
