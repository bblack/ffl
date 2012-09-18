class Move2 < ActiveRecord::Base
  belongs_to :player
  belongs_to :old_team, :class_name => "Team", :foreign_key => "old_team_id"
  belongs_to :new_team, :class_name => "Team", :foreign_key => "new_team_id"
end
