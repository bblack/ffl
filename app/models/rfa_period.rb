class RfaPeriod < ActiveRecord::Base
  belongs_to :league
  has_many :rfa_bids
  has_one :rfa_decision_period
  validates :league_id, :uniqueness => {:scope => :final_year}

  def bigredbutton(dryrun=true)
    raise StandardError.new("This RFA period has already been redbuttoned") if self.redbuttoned
    raise StandardError.new("Can't bigredbutton because RFA period is open") if self.open?
    raise StandardError.new("Can't bigredbutton because there is no decision period for this RFA period") if self.rfa_decision_period.nil?
    raise StandardError.new("Can't bigredbutton because RFA decision period is open") if self.rfa_decision_period.open?

    pvcs = []

    begin
      ActiveRecord::Base.transaction do
        self.contracts_eligible.each do |c|
          decision = RfaDecision.find_or_initialize_by_rfa_decision_period_id_and_player_id(
            rfa_decision_period.id, c.player_id)
          if decision.id.nil?
            # owner made no decision
            decision.made_by_redbutton = true
            decision.team_id = EspnRosterSpot.where(:espn_player_id => c.player.espn_id).last.team_id
            decision.keep = false # Valid by constitution as of 9 April 2013
            decision.skip_rfa_decision_period_is_open = true
            decision.save!
          end

          top_bid = self.top_bid_for(c.player_id)
          if decision.keep
            new_contract_value = top_bid ? top_bid.value : 1
          elsif top_bid.present? # and releasing
            new_contract_value = top_bid.value
          else # no bids and releasing
            new_contract_value = nil
          end
          pvc = PlayerValueChange.create(
            :league_id => self.league_id,
            :player_id => c.player_id,
            :first_year => self.final_year + 1,
            :new_value => new_contract_value,
            :last_year => self.final_year + self.league.contract_length_for_value(new_contract_value))
          pvcs << pvc
        end

        self.redbuttoned = true
        self.save!

        raise DryRunError if dryrun
      end # transaction
    rescue DryRunError => ex
      # This exception is only meant to prevent transaction from passing
    end

    return {:dryrun => dryrun, :pvcs => pvcs}
  end

  def contracts_eligible
    raise StandardError("RFA period has been redbuttoned. Check its decisions instead.") if self.redbuttoned
    self.league.signed_players_pvcs.includes(:player)
      .where("player_value_changes.last_year = ?", self.final_year)
  end

  def open?
    self.started? and not self.ended?
  end

  def started?
    self.open_date.nil? or self.open_date < Time.now
  end

  def ended?
    !self.close_date.nil? and self.close_date < Time.now
  end

  def top_bid_for(player_id)
    self.rfa_bids.select{|b| b.player_id == player_id}.sort{|x,y| y.value <=> x.value}.first
  end

end

class DryRunError < StandardError; end
