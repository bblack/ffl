class DraftPickTransaction < ActiveRecord::Base
  belongs_to :league
  belongs_to :draft
  belongs_to :from_team, :class_name => 'Team', :foreign_key => 'from_team_id'
  belongs_to :to_team, :class_name => 'Team', :foreign_key => 'to_team_id'
  belongs_to :orig_team, :class_name => 'Team', :foreign_key => 'orig_team_id'
end