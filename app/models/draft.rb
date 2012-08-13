class Draft < ActiveRecord::Base
  belongs_to :league

  before_create {|d| d.state = 'nys'}
  
  attr_reader :teams_ordered

  def start!(order_of_teams)
    if order_of_teams.sort != league.teams.collect(&:id).sort
      raise StandardError.new("Please pass an ordered list of all team ids in the league")
    end

    @teams_ordered = order_of_teams
    current_round = 0
    current_pick_in_round = 0
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