require 'nokogiri'
require 'open-uri'

namespace :db do
  
  desc "Fetch player info from espn and fill/update db"

  task :fill => :environment do
    startindex = 0

    while true
      puts "Starting from ##{startindex}..."
      uri = "http://games.espn.go.com/ffl/leaders?leagueId=172724&seasonTotals=true&startIndex=#{startindex}"

      doc = Nokogiri::HTML(open(uri))
      anchors = doc.css('.playertablePlayerName a')
      anchors = anchors.select{|a| a.child.text?}

      players = anchors.map do |a|
        sib = a.next_sibling
        p = {
          first_name: a.inner_text.split(' ', 2)[0],
          last_name: a.inner_text.split(' ', 2)[1],
          nfl_team: sib.text.split(/[[:space:]]+/)[1], # [0] is comma + optional asterisk
          position: sib.text.split(/[[:space:]]+/)[2],
          espn_id: a.get_attribute('playerid')
        }
        if p[:last_name] == 'D/ST'
          p[:nfl_team] = nil
          p[:position] = 'D/ST'
        end
        # puts p
        p
      end

      players.each do |p|
        existing_player = Player.where(espn_id: p[:espn_id]).first
        
        if existing_player
          existing_player.update_attributes!(p)
        else
          new_player = Player.create(p)
          puts "Created #{new_player.inspect}"
        end
      end

      break if anchors.none?
      startindex += anchors.count
    end

  end
end