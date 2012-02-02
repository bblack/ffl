class User < ActiveRecord::Base
  validates :name, :uniqueness => { :case_sensitive => false }
  has_many :teams
end
