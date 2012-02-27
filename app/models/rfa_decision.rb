class RfaDecision < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :rfa_decision_period
  validate :validate_team_has_player

  def validate_team_has_player
    contract = self.rfa_decision_period.rfa_period.league.get_contract_for_player(self.player_id)
    if contract.nil? or contract.team_id != self.team_id
      errors.add(:team_id, "must be the same as the team who owns this player's contract in this league.")
    end
  end

  def keepstring
    {true => 'keep', false => 'drop', nil => 'undecided'}[self.keep]
  end
end
