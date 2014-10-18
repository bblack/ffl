require 'nokogiri'
require 'open-uri'

class League < ActiveRecord::Base
  has_many :teams
  has_many :espn_roster_spots, :through => :teams
  has_many :rfa_periods
  has_many :transactions

  def completed_transactions(limit=10)
    transactions.where("completed_on is not null").order('completed_on desc').limit(limit)
  end

  def active_contracts
    contracts.where(:nixed_at => nil).where("started_at is not null")
  end

  def self.positions
    ['QB', 'RB', 'WR', 'TE', 'K', 'D/ST']
  end

  def positions
    return self.class.positions
  end

  def contract_length_for_value(value)
    [(value.to_f/15).ceil, 1].max
  end

  def signed_players_pvcs(team_id=nil)
    # The most recent PVC each player currently signed to a team in the league
    players_pvcs.
      joins('left join espn_roster_spots on espn_roster_spots.espn_player_id = players.espn_id').
      where('espn_roster_spots.team_id in (?)', team_id ? [team_id] : self.team_ids)
  end

  def players_pvcs
    # PVCs for all players with a current value, whether they're signed or not
    PlayerValueChange.
      joins('left join player_value_changes pvc2 on (player_value_changes.player_id = pvc2.player_id and player_value_changes.id < pvc2.id)').
      joins('left join players on players.id = player_value_changes.player_id').
      where('pvc2.id is null').
      where(:league_id => self.id).
      order('player_value_changes.id desc')
  end

  def clear_values_for_unsigned_players
    # For all players that have a value AND that are not on a team, set their
    # value to nil. To be used after all the RFA and resolve crap but before
    # the draft.
    r = ActiveRecord::Base.connection.execute("""
      select players.id from players
        left outer join (select * from player_value_changes order by created_at desc) pvc_latest
          on pvc_latest.player_id = players.id
        left outer join espn_roster_spots
          on players.espn_id = espn_roster_spots.espn_player_id
      where espn_roster_spots.id IS NULL
        and pvc_latest.league_id = #{id}
      group by players.id, espn_roster_spots.team_id
    """)

    player_ids = r.map{|x| x['id']}

    new_pvcs = []

    ActiveRecord::Base.transaction do
      player_ids.each do |player_id|
        new_pvcs << PlayerValueChange.create!(
          :player_id => player_id,
          :new_value => nil,
          :league_id => self.id,
          :comment   => 'clear_values_for_unsigned_players'
        )
      end
    end

    return new_pvcs
  end

  def draft(picks)
    now = Time.now

    ActiveRecord::Base.transaction do
      picks.each do |pick|
        first_year = Date.today.year

        PlayerValueChange.create!(
          pick.slice('player_id', 'new_value').merge(
            :league_id => self.id,
            :comment => "draft #{now}",
            :first_year => first_year,
            :last_year => first_year - 1 + contract_length_for_value(pick['new_value'])
          )
        )
      end
    end
  end

  def possibly_out_of_date_contracts
    # Needed to do this once after I forgot to nil out contracts before 2014 started
    year = Time.now.year
    lines = []
    q = PlayerValueChange.find_by_sql("""
        select pvc.* from player_value_changes pvc
        left join player_value_changes pvc2
        on pvc.player_id = pvc2.player_id
        and pvc2.created_at > pvc.created_at
        where pvc2.id is null
        and pvc.first_year < #{year}
    """)
    q.each do |pvc|
        pvc.player = Player.find(pvc.player_id)
        line = {:espn_id => pvc.player.espn_id, :name => pvc.player.name}

        if pvc.last_year < year
            new_pvc = PlayerValueChange.create!({
                :player_id => pvc.player.id,
                :league_id => self.id,
                :comment => 'niling out out contracts'
            })
            line[:status] = 'Most recent contract was old; nil\'d out.'
        else
            url = "http://games.espn.go.com/ffl/format/playerpop/transactions?leagueId=#{self.espn_id}&playerId=#{pvc.player.espn_id}&playerIdType=playerId&seasonId=#{year}&xhr=1"
            doc = Nokogiri::HTML(open(url))
            actions = doc.css('body div tr')

            if actions.any? {|a| a.text.match(/Selected as a Keeper/)}
                line[:status] = 'Keeper. No action taken.'
            else
                line[:status] = 'NOT KEEPER. ACTIONS THIS YEAR: ' + actions.map(&:text).join('; ')
            end
        end

        lines.push(line)
    end

    return lines
  end

end
