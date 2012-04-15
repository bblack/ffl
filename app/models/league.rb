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
  
  def get_contract_for_player(player_id)
    team_ids = self.teams.collect { |t| t.id }
    contracts = active_contracts.where(:player_id => player_id)
    raise "Huh, there's more than one contract in this league for player no. #{player_id}" if contracts.count > 1
    return contracts.first
  end
  
  def positions
    ['QB', 'RB', 'WR', 'TE', 'PK', 'Def']
  end

  def contract_length_for_value(value)
    [(value.to_f/15).ceil, 1].max
  end

end
