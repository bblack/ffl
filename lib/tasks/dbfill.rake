require 'nokogiri'
require 'open-uri'

namespace :db do
  
  desc "Fetch player info from myfantasyleague and fill/update db"
  task :fill => :environment do
    require 'net/http'
    
    responsebody = Net::HTTP.get(URI.parse("http://football.myfantasyleague.com/2013/player_listing?POSITION=*&TEAM=*"))
    puts responsebody
    
    #re = Regexp.new('<a href="player?P=(.*?)">(.*), .* ([^ ]*) ([^ ]*)</a>')
    re = Regexp.new('<a href="player\?P=(.*?)">(.*?), (.*) ([^ ]*) ([^ ]*)</a>')
    matches = responsebody.scan(re)
    puts "#{matches.count} players read from MFL"
    players_created_count = 0
    players_updated_count = 0
    matches.each do |match|
      atts = {
        :mfl_id => match[0],
        :last_name => match[1],
        :first_name => match[2],
        :nfl_team => match[3],
        :position => match[4]
      }
      matches_in_db = Player.where(:mfl_id => atts[:mfl_id])
      if matches_in_db.count == 0
        Player.create(atts)
        players_created_count += 1
      elsif matches_in_db.count == 1
        matches_in_db.first.update_attributes(atts)
      else
        puts "That's odd... found multiple players in DB with mfl_id #{atts[:mfl_id]}"
      end
    end
    puts "#{players_created_count} players created"
  end

  task :fill_espn => :environment do
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