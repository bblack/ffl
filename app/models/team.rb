class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts
  belongs_to :league
end
