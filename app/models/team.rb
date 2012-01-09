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
  
end
