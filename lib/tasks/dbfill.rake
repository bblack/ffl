require 'nokogiri'
require 'open-uri'

namespace :db do
  desc "Fetch player info from espn and fill/update db"

  task :fill => :environment do
    next_page_url = "http://games.espn.go.com/ffl/leaders?leagueId=172724&seasonTotals=true&startIndex=0"

    while next_page_url.present?
      puts "#{next_page_url}..."
      doc = Nokogiri::HTML(open(next_page_url))
      next_page_a = doc.css('.paginationNav a')
        .select{|a| a.text.match /NEXT/}
        .first
      next_page_url = next_page_a ? next_page_a.attribute('href').value : nil
      anchors = doc.css('.playertablePlayerName a').select{|a| a.child.text?}

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
    end

  end
end
