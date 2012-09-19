class Move2 < ActiveRecord::Base
  belongs_to :player
  belongs_to :league
  belongs_to :old_team, :class_name => "Team", :foreign_key => "old_team_id"
  belongs_to :new_team, :class_name => "Team", :foreign_key => "new_team_id"

  validates_each :old_team, :new_team do |model, att, value|
    model.errors.add(att, 'must belong to league') unless value.nil? || value.league_id == model.league_id
  end
end
