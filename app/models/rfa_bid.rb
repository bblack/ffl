class RfaBid < ActiveRecord::Base
  belongs_to :rfa_period
  belongs_to :player
  
  validates :value, :presence => true
  validates :value, :numericality => {:only_integer => true, :greater_than => 0}
  validates :rfa_period_id, :presence => true
  validates :player_id, :presence => true
  validates :team_id, :presence => true

  validates_each :value, :on => :create do |model, att, value|
    biggest_bid = RfaBid.where(:rfa_period_id => model.rfa_period_id, :player_id => model.player_id).maximum(:value)
    model.errors.add(att, "must exceed the greatest bid value which is #{biggest_bid}") if biggest_bid and value <= biggest_bid
  end
end
