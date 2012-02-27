class RfaDecisionPeriod < ActiveRecord::Base
  has_many :rfa_decisions
  belongs_to :rfa_period

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
