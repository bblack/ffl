class RfaBid < ActiveRecord::Base
  belongs_to :rfa_period
  belongs_to :player
  belongs_to :team
  
  validates :value, :presence => true
  validates :value, :numericality => {:only_integer => true, :greater_than => 0}
  validates :rfa_period_id, :presence => true
  validates :player_id, :presence => true
  validates :team_id, :presence => true

  validates_each :value, :on => :create do |model, att, value|
    biggest_bid = RfaBid.where(:rfa_period_id => model.rfa_period_id, :player_id => model.player_id).maximum(:value)
    model.errors.add(att, "must exceed the greatest bid value which is #{biggest_bid}") if biggest_bid and value <= biggest_bid
  end
  
  validates_each :team_id do |model, att, value|
    team = Team.includes(:league).find(value)
    rfa_period = RfaPeriod.includes(:league).find(model.rfa_period_id)
    if team.league.id != rfa_period.league.id
      model.errors.add(att, "must belong to the same league that the RFA period does")
    end
  end
  
  validates_each :value, :on => :create do |model, att, value|
    max_bid_allowed = model.team.max_rfa_bid(model.rfa_period_id)
    unless max_bid_allowed.nil?
      if value > max_bid_allowed
        model.errors.add(att, "must not exceed the team's available payroll plus payroll in expiring contracts (#{max_bid_allowed})")
      end
    end
  end
  
  validates_each :rfa_period_id do |model, att, value|
    rfa = RfaPeriod.find value
    model.errors.add(att, " must be a currently open RFA period") if not rfa.open?
  end

  validates_each :team_id do |model, att, value|
    if self.rfa_period.league.get_contract_for_player(model.player_id).team_id == value
      model.errors.add(att, " must not be the same team who currently owns the player")
    end
  end
  
end
