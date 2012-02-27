class RfaPeriod < ActiveRecord::Base
  belongs_to :league
  has_many :rfa_bids
  has_one :rfa_decision_period
  validates :league_id, :uniqueness => true
  
  def contracts_eligible
    self.league.contracts.includes(:player).where("first_year + length - 1 <= ?", self.final_year)
  end
  
  def open?
    self.started? and not self.ended?
  end
  
  def started?
    self.open_date.nil? or self.open_date < Time.now
  end
  
  def ended?
    !self.close_date.nil? and self.close_date < Time.now
  end
  
end
