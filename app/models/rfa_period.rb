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

    begin
      ActiveRecord::Base.transaction do
        self.contracts_eligible.each do |c|
          nixed_contracts << c

          top_bid = self.top_bid_for(c.player_id)
          new_contract_value = top_bid ? top_bid.value : 1
          decision = self.rfa_decision_period.rfa_decisions.where(:player_id => c.player_id).first
          new_contract = PlayerValueChange.new(
            :player_id => c.player_id,
            :first_year => self.final_year + 1,
            :value => new_contract_value,
            :last_year => self.final_year + self.league.contract_length_for_value(new_contract_value)
            )

          if decision and decision.keep
            new_contract.team_id = c.team_id
            new_contract.save!
            new_contracts << new_contract
          elsif top_bid
            new_contract.team_id = top_bid.team_id
            new_contract.save!
            new_contracts << new_contract
          else
            # Owner releases, and there are no bids.
          end
        end # rfa-eligible contracts

        self.redbuttoned = true
        self.save!

        raise DryRunError if dryrun
      end # transaction
    rescue DryRunError => ex
      # This exception is only meant to prevent transaction from passing
    end

    return {
      :dryrun => dryrun,
      :nixed_contracts => nixed_contracts,
      :new_contracts => new_contracts
      }
  end

  def contracts_eligible
    self.league.signed_players_pvcs.includes(:player)
      .where("last_year = ?", self.final_year)
      .collect(&:player)
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