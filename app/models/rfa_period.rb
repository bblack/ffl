class RfaPeriod < ActiveRecord::Base
  belongs_to :league
  
  def contracts_eligible
    self.league.contracts.includes(:player).where("first_year + length - 1 <= ?", self.final_year)
  end
  
end
