class RfaDecisionPeriod < ActiveRecord::Base
  has_many :rfa_decisions
  belongs_to :rfa_period
end
