class PlayerValueChange < ActiveRecord::Base
  belongs_to :player
  belongs_to :league

  def length
    if last_year && first_year
      last_year - first_year + 1
    else
      nil
    end
  end
end
