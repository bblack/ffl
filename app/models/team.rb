class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  def payroll
    ret = 0
    contracts.each { |c| ret += c.value }
    ret
  end
  
  def payroll_available
    self.league.salary_cap.nil? ? nil : self.league.salary_cap - self.payroll 
  end
  
  def under_cap?
    payroll_available.nil? or payroll_available > 0
  end
  
end
