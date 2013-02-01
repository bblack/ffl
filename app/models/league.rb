class League < ActiveRecord::Base
  has_many :teams
  has_many :contracts, :through => :teams
  has_many :rfa_periods
  has_many :transactions

  def completed_transactions(limit=10)
    transactions.where("completed_on is not null").order('completed_on desc').limit(limit)
  end

  def active_contracts
    contracts.where(:nixed_at => nil).where("started_at is not null")
  end
  
  def positions
    ['QB', 'RB', 'WR', 'TE', 'PK', 'Def']
  end

  def contract_length_for_value(value)
    [(value.to_f/15).ceil, 1].max
  end

  def signed_players_pvcs(team_id=nil)
    # The most recent PVC for the league for all players,
    # or for players currently signed to a particular team
    # TODO: Filter out any pvcs that ended before this season
    # TODO: Any players w/o valid current pvcs take on 1-yr, 1-pv
    PlayerValueChange.
      joins('inner join players on players.id = player_value_changes.player_id').
      joins('inner join espn_roster_spots on espn_roster_spots.espn_player_id = players.espn_id').
      group('player_value_changes.player_id', 'player_value_changes.id').
      order('player_value_changes.created_at desc').
      where(:team_id => (team_id || self.team_ids))
  end

end
