class EspnRosterSpot < ActiveRecord::Base
  belongs_to :player, :foreign_key => 'espn_player_id', :primary_key => 'espn_id'
  belongs_to :team

  def current
    self
      .joins('left join espn_roster_spots ers2 ' +
        'on espn_roster_spots.league_id = ers2.league_id ' +
        'and espn_roster_spots.espn_player_id = ers2.espn_player_id ' +
        'and espn_roster_spots.id < ers2.id')
      .where('ers2.id is null')
  end
end
