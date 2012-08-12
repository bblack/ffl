class Draft < ActiveRecord::Base
  #belongs_to :league

  attr_reader :type
  attr_reader :teams_ordered

  def initialize
    # Ordered for first round (just by name while debugging)
    @teams_ordered = League.find(1).teams.sort_by! &:name
    current_round = 0
    current_pick_in_round  = 0
  end

  def current_pick
    [current_round, current_pick_in_round]
  end

  def next_pick
    if current_pick[1] < self.teams_ordered.count - 1
      [current_pick[0], current_pick[1] + 1]
    else
      [current_pick[0] + 1, 0]
    end
  end

  def advance!
    # For use internally following a pick;
    # For use externally in skipping a pick
    current_round, current_pick_in_round = next_pick
  end

end