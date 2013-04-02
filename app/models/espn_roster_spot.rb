class EspnRosterSpot < ActiveRecord::Base
  belongs_to :player, :foreign_key => 'espn_player_id', :primary_key => 'espn_id'
  belongs_to :team
end
