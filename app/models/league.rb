class League < ActiveRecord::Base
  has_many :teams
  has_many :espn_roster_spots, :through => :teams
  has_many :rfa_periods
  has_many :transactions

  def completed_transactions(limit=10)
    transactions.where("completed_on is not null").order('completed_on desc').limit(limit)
  end

  def active_contracts
    contracts.where(:nixed_at => nil).where("started_at is not null")
  end

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

    PlayerValueChange.
      joins('left join player_value_changes pvc2 on (player_value_changes.player_id = pvc2.player_id and player_value_changes.id < pvc2.id)').
      joins('left join players on players.id = player_value_changes.player_id').
      joins('left join espn_roster_spots on espn_roster_spots.espn_player_id = players.espn_id').
      where('pvc2.id is null').
      where('espn_roster_spots.team_id in (?)', team_id ? [team_id] : self.team_ids).
      order('player_value_changes.id desc')
  end

  def clear_values_for_unsigned_players
    # For all players that have a value AND that are not on a team, set their
    # value to nil. To be used after all the RFA and resolve crap but before
    # the draft.
    r = ActiveRecord::Base.connection.execute("""
      select players.id from players
        left outer join (select * from player_value_changes order by created_at desc) pvc_latest
          on pvc_latest.player_id = players.id
        left outer join teams on teams.id = pvc_latest.team_id
        left outer join espn_roster_spots
          on players.espn_id = espn_roster_spots.espn_player_id
      where espn_roster_spots.id IS NULL
        and teams.league_id = #{id}
      group by players.id, espn_roster_spots.team_id
    """)

    player_ids = r.map{|x| x['id']}

    new_pvcs = []

    ActiveRecord::Base.transaction do
      player_ids.each do |player_id|
        new_pvcs << PlayerValueChange.create!(
          :player_id => player_id,
          :new_value => nil,
          :team_id   => team_ids.first, # whatever, i need to replace this with league_id
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
        first_year = Date.today.year

        PlayerValueChange.create!(
          pick.slice('player_id', 'new_value').merge(
            :team_id => team_ids.first, # todo - change pvc.team_id to league_id
            :comment => "draft #{now}",
            :first_year => first_year,
            :last_year => first_year - 1 + contract_length_for_value(pick['new_value'])
          )
        )
      end
    end
  end

end
