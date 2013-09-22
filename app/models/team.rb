require 'open-uri'

class Team < ActiveRecord::Base
  has_many :contracts # deprecado
  belongs_to :league
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  has_many :espn_roster_spots
  has_many :players, :through => :espn_roster_spots

  def players_pvcs
    self.league.signed_players_pvcs(self.id)
  end
  
  def payroll
    rosterspots = EspnRosterSpot.where(:team_id => self.id)
    playerids = Player.where(:espn_id => rosterspots.map(&:espn_player_id)).map(&:id)
    teamids = league.team_ids
    # fuck it
    playerids.inject(0) do |m, pid|
      # todo - change pvc team_id to league_id
      m + (PlayerValueChange.where(:team_id => teamids, :player_id => pid).last.new_value || 0)
    end
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

  def fetch_espn_roster
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
    
    self.transaction do
      self.espn_roster_spots.delete_all
      espn_hash.keys.each do |espn_id|
        EspnRosterSpot.create(:espn_player_id => espn_id, :team_id => self.id)

        player = Player.find(:espn_player_id => espn_id)
        last_pvc = PlayerValueChange.where(
          :player_id => player.id,
          :team_id => league.team_ids # todo - change to league id
        ).last

        if (last_pvc.nil? || last_pvc.new_value.nil?)
          new_value = 1
          start_year = Date.today.year

          # todo - change pvc team_id to league_id
          PlayerValueChange.create!(
            :player_id => player.id,
            :team_id => id,
            :new_value => new_value,
            :first_year => start_year,
            :last_year => start_year - 1 + league.contract_length_for_value(new_value),
            :comment => 'free agent pickup')
        end
      end
      self.espn_roster_last_updated = Time.now
      self.save!
    end

    players_missing = espn_hash.slice(*(espn_hash.keys - Player.where(:espn_id => espn_hash.keys).collect{|e| e.espn_id.to_s}))
    raise StandardError.new("Players missing: #{players_missing.collect{|k| k.join(' ')}.join(', ')}") if players_missing.any?

    self.players(true)
  end
  
end
