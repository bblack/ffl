class Player < ActiveRecord::Base
  has_many :contracts
  
  def self.positions_with_photos
    ['QB', 'RB', 'WR', 'TE', 'PK']
  end
  
  require 'uri'
  require 'net/http'
  def try_fetch_espn_id
    raise WrongPlayerPositionError if not Player.positions_with_photos.member? self.position
    url = "http://search.espn.go.com/#{self.first_name} #{self.last_name}".gsub(' ', '-')
    response = Net::HTTP.get_response(URI.parse(url))
    re = Regexp.new('http:\/\/sports\.espn\.go\.com\/nfl\/players\/profile\?playerId=(\d*)')
    matches = response.body.scan(re)
    playerids = []
    matches.each {|m| playerids << m[0] if not playerids.member? m[0]}
    if playerids.count != 1
      Rails.logger.error "Player #{self.id} (#{self.first_name} #{self.last_name}) returned #{playerids.count} ids from ESPN"
    end
    playerids[0]
  end
  
  def espn_img_url
    begin
      raise WrongPlayerPositionError if not Player.positions_with_photos.member? self.position
      return "http://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/#{self.espn_id}.png&w=100&h=150&scale=crop&background=0xcccccc&transparent=true"
    rescue
      return "/images/player_no_photo.png"
    end
  end
  
end

class WrongPlayerPositionError < StandardError
end