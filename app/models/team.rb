require 'open-uri'

class Team < ActiveRecord::Base
  has_many :contracts # deprecado
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  def players
    @_players ||= espn_players
    @_players
  end
  
  def payroll
    pvcs = PlayerValueChange.where(:team_id => self.league.team_ids, :player_id => players.collect(&:id))
      .group(:player_id, :id)
      .order('created_at desc')
    pvcs.to_a.sum(&:new_value)
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
      expiring_contracts = rfa_period.contracts_eligible.where(:team_id => self.id)
      expiring_contracts_value = (expiring_contracts.collect { |c| c.value }).inject(:+)
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

  def espn_players
    raise StandardError.new("league's espn_id is nil") if self.league.espn_id == nil
    raise StandardError.new("team's espn_id is nil") if self.espn_id == nil

    doc = Nokogiri::HTML(open(self.espn_url))
    player_link_elements = doc.css('.playertablePlayerName a')

    # Map espn_id => name
    espn_hash = Hash[
      player_link_elements
        .select{|e| e.inner_text.present?}
        .collect{|e| [e.attributes['playerid'].value, e.inner_text]}
    ]
    
    # Fetch players from database
    players = Player.where(:espn_id => espn_hash.keys)
    players_missing = espn_hash.slice(*
      espn_hash.keys.select do |espnid|
        players.none?{|p| p.espn_id.to_s == espnid.to_s}
      end
    )
    raise StandardError.new("DB missing players: #{players_missing.to_a.join(', ')}") if players_missing.any?
    return players
  end
  
end
