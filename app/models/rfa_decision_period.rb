class RfaDecisionPeriod < ActiveRecord::Base
  has_many :rfa_decisions
  belongs_to :rfa_period

  def open?
    self.started? and not self.ended?
  end
  
  def started?
    self.open_date.nil? or self.open_date < Time.now
  end
  
  def ended?
    !self.close_date.nil? and self.close_date < Time.now
  end

  def tentative_payroll_for_team(team_id)
    # Calculate a team's payroll for all non-RFA contracts,
    # plus the minimum salary required to keep any current RFAs

    team = Team.find(team_id)

    nonrfas = 0
    team.contracts.each do |c|
      unless self.rfa_period.contracts_eligible.any? { |ce| ce.player_id == c.player_id }
        nonrfas += c.value 
      end
    end
    
    rfakeeps = 0
    team.contracts.each do |c|
      if self.rfa_decisions.any? { |d| d.player_id == c.player_id and d.keep }
        top_bid = self.rfa_period.top_bid_for(c.player_id)
        rfakeeps += top_bid.nil? ? 1 : top_bid.value
      end
    end

    return nonrfas + rfakeeps
  end

end
