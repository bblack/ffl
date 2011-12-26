class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts
end
