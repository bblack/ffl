require 'nokogiri'
require 'open-uri'

class League < ActiveRecord::Base
  has_many :teams
  has_many :espn_roster_spots, :through => :teams,
    :conditions => proc {['roster_revision = ?', self.roster_revision]}
  has_many :rfa_periods

  def self.positions
    ['QB', 'RB', 'WR', 'TE', 'K', 'D/ST']
  end

  def positions
    return self.class.positions
  end

  def contract_length_for_value(value)
    [(value.to_f/15).ceil, 1].max
  end

  def signed_players_pvcs(team_id=nil)
    # The most recent PVC each player currently signed to a team in the league
    players_pvcs
      .joins('left join espn_roster_spots on espn_roster_spots.espn_player_id = players.espn_id')
      .where('espn_roster_spots.team_id in (?)', team_id ? [team_id] : self.team_ids)
      .where('espn_roster_spots.roster_revision = ?', self.roster_revision)
  end

  def players_pvcs
    # PVCs for all players with a current value, whether they're signed or not
    PlayerValueChange.
      joins('left join player_value_changes pvc2 on (player_value_changes.player_id = pvc2.player_id and player_value_changes.id < pvc2.id)').
      joins('left join players on players.id = player_value_changes.player_id').
      where('pvc2.id is null').
      where(:league_id => self.id).
      order('player_value_changes.id desc')
      .where("player_value_changes.last_year >= #{self.current_season}")
  end

  def unsigned_players
    # warning: raw substitution here because ? doesn't work with #joins
    Player
      .joins("
        left outer join espn_roster_spots ers on players.espn_id = ers.espn_player_id
        and ers.roster_revision = '#{self.roster_revision}'
      ")
      .where('ers.id is null')
  end

  def clear_values_for_unsigned_players
    # For all players that have a value AND that are not on a team, set their
    # value to nil. To be used after all the RFA and resolve crap but before
    # the draft.
    new_pvcs = []

    ActiveRecord::Base.transaction do
      unsigned_players.each do |player|
        new_pvcs << PlayerValueChange.create!(
          :player_id => player.id,
          :new_value => nil,
          :league_id => self.id,
          :comment   => 'clear_values_for_unsigned_players'
        )
      end
    end

    return new_pvcs
  end

  def draft(picks)
    now = Time.now

    ActiveRecord::Base.transaction do
      picks.each do |pick|
        first_year = self.current_season

        PlayerValueChange.create!(
          pick.slice('player_id', 'new_value').merge(
            :league_id => self.id,
            :comment => "draft #{now}",
            :first_year => first_year,
            :last_year => first_year - 1 + contract_length_for_value(pick['new_value'])
          )
        )
      end
    end
  end

  def fetch_espn_rosters
    offset = 0
    slots = []
    while true do
      # avail: -1: all, 1: available, 2: free agents, 3: on waivers, 4: on rosters, 5: keepers
      url = "http://games.espn.com/ffl/freeagency?leagueId=#{self.espn_id}&seasonId=2016&startIndex=#{offset}&avail=4"
      doc = Nokogiri::HTML(open(url))
      doc.css('table.playerTableTable tr.pncPlayerRow').each do |tr|
        espn_player_id = tr.attributes['id'].value.match(/plyr(\d+)/)[1]
        espn_team_id = tr.css('td a')
          .map {|a| a.attributes['href'].value}
          .find {|href| href.match(/\/ffl\/clubhouse/)}
          .match(/\/ffl\/clubhouse\?.*teamId=(\d+)/)[1]
        slots << {espn_player_id: espn_player_id, espn_team_id: espn_team_id}
      end
      break if !doc.css('.paginationNav a').last.text.match(/NEXT/)
      offset += 50
    end
    return slots
  end

  def update_espn_rosters
    roster_spots = self.fetch_espn_rosters
    roster_revision = SecureRandom::uuid
    team_espn_id_to_id = {}
    self.teams.each {|t| team_espn_id_to_id[t.espn_id] = t.id}
    current_values_and_players = players_pvcs.includes(:player)
    ActiveRecord::Base.transaction do
      roster_spots.each do |rs|
        EspnRosterSpot.create!({ #ugh
          espn_player_id: rs[:espn_player_id],
          team_id: team_espn_id_to_id[rs[:espn_team_id]],
          roster_revision: roster_revision
        })
        player_last_pvc = current_values_and_players.all.find {|pvc| pvc.player.espn_id.to_s == rs[:espn_player_id]}
        if (player_last_pvc.nil? || player_last_pvc.new_value.nil?)
          PlayerValueChange.create!(
            league_id: self.id,
            player_id: Player.find_by_espn_id(rs[:espn_player_id]).id,
            new_value: 1,
            first_year: self.current_season,
            last_year: self.current_season + contract_length_for_value(1) - 1,
            comment: 'FA pickup fetched from espn'
          )
        end
      end
      self.update_attributes(roster_revision: roster_revision)
    end
  end

  def current_season
    # TODO
    #  Date.today.year
    2016
  end
end
