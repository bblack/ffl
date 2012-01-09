class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts
  belongs_to :league
  
  def payroll
    ret = 0
    contracts.each { |c| ret += c.value }
    ret
  end
  
end
