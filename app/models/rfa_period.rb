class RfaPeriod < ActiveRecord::Base
  belongs_to :league
  has_many :rfa_bids
  validates :league_id, :uniqueness => true
  
  def contracts_eligible
    self.league.contracts.includes(:player).where("first_year + length - 1 <= ?", self.final_year)
  end
  
end
