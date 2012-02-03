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
    unless model.team.payroll_available.nil?
      if value > model.team.payroll_available
        model.errors.add(att, "must not exceed the team's available payroll total (#{model.team.payroll_available})")
      end
    end
  end
  
end
