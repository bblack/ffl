require 'open-uri'

class Team < ActiveRecord::Base
  has_many :contracts
  has_many :players, :through => :contracts # but should exclude nixed contracts!
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  def payroll
    ret = 0
    contracts.where(:nixed_at => nil).each { |c| ret += c.value }
    ret
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
    espn? ? "http://games.espn.go.com/ffl/clubhouse?leagueId=#{self.league.espn_id}&teamId=#{self.espn_id}" : nil
  end

  def compare_to_espn
    raise StandardError.new("league's espn_id is nil") if self.league.espn_id == nil
    raise StandardError.new("team's espn_id is nil") if self.espn_id == nil

    doc = Nokogiri::HTML(open(self.espn_url))
    player_link_elements = doc.css('.playertablePlayerName a')
    players_on_espn = Set.new
    player_link_elements.each do |el|
      players_on_espn << {
        'espn_id' => el.attributes['playerid'].value,
        'full_name' => el.inner_text
        } if el.inner_text.present?
    end
    players_in_db = Set.new(self.contracts.includes(:player).where(:nixed_at => nil).collect{|c| {'espn_id' => c.player.espn_id.to_s, 'full_name' => c.player.full_name}})
    players_only_on_espn = players_on_espn.select{|p| players_in_db.none? {|q| q['espn_id'] == p['espn_id'] }}
    players_only_in_db = players_in_db.select{|p| players_on_espn.none? {|q| q['espn_id'] == p['espn_id'] }}

    return {:espn => players_only_on_espn, :db => players_only_in_db}
  end
  
end
