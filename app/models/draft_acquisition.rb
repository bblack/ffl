class DraftAcquisition < ActiveRecord::Base
  belongs_to :draft_nomination
  belongs_to :team
end