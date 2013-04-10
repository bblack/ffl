class PlayerValueChange < ActiveRecord::Base
  belongs_to :player
  belongs_to :team # The team who signed the contract causing the value change. nil if a drop (i.e. new_value == nil)
  validates :team, :presence => true # Must exist in the right league. consider changing to league_id
end
