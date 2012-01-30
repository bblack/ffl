class League < ActiveRecord::Base
  has_many :teams
  has_many :contracts, :through => :teams
  has_many :rfa_periods
  
  def get_contract_for_player(player_id)
    team_ids = self.teams.collect { |t| t.id }
    contracts = Contract.where(:player_id => player_id, :team_id => team_ids)
    raise "Huh, there's more than one contract in this league for player no. #{player_id}" if contracts.count > 1
    return contracts.first
  end
  
  def positions
    ['QB', 'RB', 'WR', 'TE', 'PK', 'Def']
  end
end
