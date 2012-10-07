require 'open-uri'

class Team < ActiveRecord::Base
  has_many :contracts # deprecado
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  def moves_to_still_on_team
    # Get the most recent move to or from this team for each player
    # that was ever on this team. Then a player is on this team currently iff
    # their latest move is *to* the team.
    q = <<-EOD
      select * from move2s
        where id in 
          (select max(id) from move2s
            where old_team_id = #{self.id} or new_team_id = #{self.id} group by player_id)
        and new_team_id = #{self.id}
    EOD
    
    move_ids = Move2.connection.select_all(q).collect{|m| m['id']}
    Move2.find(move_ids)
  end

  def players
    moves_to = moves_to_still_on_team
    return Player.where(:id => moves_to.collect{|m| m['player_id']})
  end
  
  def payroll
    return 0 if players.empty?

    q = <<-EOD
      select max(id) as move_id from move2s
        where new_pv is not null
        and player_id in (#{players.collect(&:id).join(',')}) 
        group by player_id
    EOD

    salaries_for_players = Move2.connection.select_all(q)
    move_ids_for_salaries = salaries_for_players.collect{|row| row['move_id']}

    return Move2.where(:id => move_ids_for_salaries).sum(:new_pv)
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
    players_in_db = Set.new(players.collect{|p| {'espn_id' => p.espn_id.to_s, 'full_name' => p.full_name}})
    players_only_on_espn = players_on_espn.select{|p| players_in_db.none? {|q| q['espn_id'] == p['espn_id'] }}
    players_only_in_db = players_in_db.select{|p| players_on_espn.none? {|q| q['espn_id'] == p['espn_id'] }}

    return {:espn => players_only_on_espn, :db => players_only_in_db}
  end
  
end
