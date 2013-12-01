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
        p = {name: a.inner_text, id: a.get_attribute('playerid'), :team_and_pos => sib.text}
        puts p
        p
      end

      matching_players = Player.where(espn_id: players.map{|p| p[:id]})
      puts "#{matching_players.count} matches"
      matching_player_ids = matching_players.map(&:espn_id)
      unmatching_players = players.reject{|p| matching_player_ids.member? p[:id].to_i}

      puts "#{unmatching_players.count} not found"
      unmatching_players.each do |u|
        puts "Enter ID for #{u[:name]}#{u[:team_and_pos]}, or leave blank to create new player."
        puts "Possible matches: #{Player.where(:first_name => u[:name].split[0], :last_name => u[:name].split[1]).all}"
        existing_player_id = STDIN.gets.strip
        if (existing_player_id)
          p = Player.find(existing_player_id)
          p.espn_id = u[:id]
          p.save!
        else
          p = Player.create(
            name: u[:name] + u[:team_and_pos],
            espn_id: u[:id]
          )
        end
      end

      break if anchors.none?
      startindex += anchors.count
    end

  end
end