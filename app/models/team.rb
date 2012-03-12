class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  def payroll
    ret = 0
    contracts.where(:nixed_at => nil).each { |c| ret += c.value }
    ret
  end
  
  def payroll_available
    self.league.salary_cap.nil? ? nil : self.league.salary_cap - self.payroll 
  end
  
  def under_cap?
    payroll_available.nil? or payroll_available > 0
  end
  
  def max_rfa_bid(rfa_period_id)
    rfa_period = RfaPeriod.find rfa_period_id
    raise StandardError if rfa_period.league_id != self.league_id
    
    if payroll_available.nil?
      return nil
    else
      expiring_contracts = rfa_period.contracts_eligible.where(:team_id => self.id)
      expiring_contracts_value = (expiring_contracts.collect { |c| c.value }).inject(:+)
      return self.payroll_available + expiring_contracts_value
    end
  end
  
end
