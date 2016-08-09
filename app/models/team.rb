require 'open-uri'

class Team < ActiveRecord::Base
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  has_many :espn_roster_spots,
    :conditions => proc {['roster_revision = ?', self.league.roster_revision]}
  has_many :players, :through => :espn_roster_spots

  def players_pvcs
    self.league.signed_players_pvcs(self.id)
  end

  def payroll
    self.players_pvcs.all.sum(&:new_value)
  end

  def payroll_available
    self.league.salary_cap.nil? ? nil : self.league.salary_cap - self.payroll
  end

  def under_cap?
    payroll_available.nil? or payroll_available > 0
  end

  def max_rfa_bid(rfa_period_id)
    rfa_period = RfaPeriod.find rfa_period_id
    raise StandardError if rfa_period.league_id != self.league_id

    if payroll_available.nil?
      return nil
    else
      expiring_contracts = rfa_period.contracts_eligible.where(:player_id => self.players.collect(&:id))
      expiring_contracts_value = expiring_contracts.all.sum{|c| c.new_value}
      return self.payroll_available + expiring_contracts_value
    end
  end

  def espn?
    self.espn_id != nil and self.league.espn_id != nil
  end

  def espn_url
    # can't use mobile as of 2012-09-19 only because the links for D/ST don't contain playerid, only a link to that NFL team
    "http://games.espn.go.com/ffl/clubhouse?leagueId=#{league.espn_id}&teamId=#{espn_id}" if espn?
  end

end
