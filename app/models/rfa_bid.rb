class RfaBid < ActiveRecord::Base
  belongs_to :rfa_period
  belongs_to :player
  validates_each :value do |model, att, value|
    model.errors.add(att, 'must be positive') if value <= 0    
  end
end
