class User < ActiveRecord::Base
  validates :name, :uniqueness => { :case_sensitive => false }
  validates :name, :format => { :with => /\A[a-z0-9]+\z/, :message => "Username must include only lowercase letters and numerals" }
  validates :email, :uniqueness => { :case_sensitive => false }
  has_many :teams
end
