class RfaPeriod < ActiveRecord::Base
  belongs_to :league
  has_many :rfa_bids
  has_one :rfa_decision_period
  validates :league_id, :uniqueness => true
  
  def bigredbutton(dryrun=true)
    raise StandardError.new("This RFA period has already been redbuttoned") if self.redbuttoned
    raise StandardError.new("Can't bigredbutton because RFA period is open") if self.open?
    raise StandardError.new("Can't bigredbutton because there is no decision period for this RFA period") if self.rfa_decision_period.nil?
    raise StandardError.new("Can't bigredbutton because RFA decision period is open") if self.rfa_decision_period.open?

    nixed_contracts = []
    new_contracts = []

    Contract.transaction do
      self.contracts_eligible.each do |c|
        c.nix("big red button from rfa period no. #{self.id}")
        c.save! unless dryrun
        nixed_contracts << c

        top_bid = self.top_bid_for(c.player_id)
        new_contract_value = top_bid ? top_bid.value : 1
        decision = self.rfa_decision_period.rfa_decisions.where(:player_id => c.player_id).first
        new_contract = Contract.new(
          :player_id => c.player_id,
          :first_year => self.final_year + 1,
          :value => new_contract_value,
          :length => self.league.contract_length_for_value(new_contract_value)
          )

        if decision and decision.keep
          new_contract.team_id = c.team_id
          new_contract.save! unless dryrun
          new_contracts << new_contract
        elsif top_bid
          new_contract.team_id = top_bid.team_id
          new_contract.save! unless dryrun
          new_contracts << new_contract
        else
          # Owner releases, and there are no bids.
        end
      end # rfa-eligible contracts

      unless dryrun
        self.redbuttoned = true
        self.save!
      end
    end # transaction

    return {
      :dryrun => dryrun,
      :nixed_contracts => nixed_contracts,
      :new_contracts => new_contracts
      }
  end

  def contracts_eligible
    self.league.contracts.includes(:player)
      .where("first_year + length - 1 <= ?", self.final_year)
      .where((self.close_date ? "nixed_at IS NULL OR nixed_at >= ?" : "nixed_at IS NULL" ), self.close_date) # For showing old RFA periods accurately. Pay attention to the conditional/sql string substitution
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
