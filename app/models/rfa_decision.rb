class RfaDecision < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :rfa_decision_period
  validate :validate_team_has_player
  validate :rfa_decision_period_is_open
  after_validation { reset_skip_flags }
  attr_accessor :skip_rfa_decision_period_is_open

  def validate_team_has_player
    contract = self.team.players_pvcs.where(:player_id => self.player_id)
    if contract.none?
      errors.add(:team_id, "must be the same as the team who owns this player's contract in this league.")
    end
  end

  def rfa_decision_period_is_open
    return if skip_rfa_decision_period_is_open
    if not rfa_decision_period.open?
      errors.add(:rfa_decision_period, "must be open")
    end
  end

  def keepstring
    {true => 'keep', false => 'drop', nil => 'undecided'}[self.keep]
  end

  def reset_skip_flags
    skip_rfa_decision_period_is_open = false
  end
end
