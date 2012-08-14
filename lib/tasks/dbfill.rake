namespace :db do
  
  desc "Fetch player info from myfantasyleague and fill/update db"
  task :fill => :environment do
    require 'net/http'
    
    responsebody = Net::HTTP.get(URI.parse("http://football.myfantasyleague.com/2012/player_listing?POSITION=*&TEAM=*"))
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
end