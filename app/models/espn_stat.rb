require 'open-uri'

class EspnStat < ActiveRecord::Base
  belongs_to :player, :primary_key => 'espn_id'
  belongs_to :league, :primary_key => 'espn_id'
  
  def self.pull(espn_league_id, week, season)
    start = 0
    got_all = false

    until got_all
      if week.nil?
        url = "http://games.espn.go.com/ffl/leaders?leagueId=#{espn_league_id}&seasonId=#{season}&startIndex=#{start}&seasonTotals=true"
      else
        url = "http://games.espn.go.com/ffl/leaders?leagueId=#{espn_league_id}&seasonId=#{season}&startIndex=#{start}&scoringPeriodId=#{week}"
      end
      doc = Nokogiri::HTML(open(url))
      player_rows = doc.css('.pncPlayerRow')

      player_rows.each do |tr|
        espn_player_id = /.*?(\d+)\Z/.match(tr.attr('id'))[1].to_i
        stat = self.find_or_initialize_by_player_id_and_league_id_and_week_and_season(
          espn_player_id, espn_league_id, week, season)
        points = tr.css('.appliedPoints').text
        if points == "--"
          got_all = true
          return
        end
        stat.points = Integer(points)
        stat.save!
      end

      start += player_rows.count
    end
  end
end
