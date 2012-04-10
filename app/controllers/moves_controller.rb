class MovesController < ApplicationController
  class DerpError < StandardError; end

  def destroy
    Move.destroy params[:id]
    add_flash(:notice, false, "Deleted move ##{params[:id]}")
    redirect_to :back
  end

  def create
    transaction = Transaction.find(params[:transaction_id])
    raise DerpError.new("This transaction doesn't belong to you") unless transaction.user_id == @current_user.id
    old_contract = @current_league.get_contract_for_player(params[:player_id])
    team = Team.find(params[:team_id]) if params[:team_id].present?
    move = Move.new(:transaction_id => params[:transaction_id])
    if params[:type] == 'add'
      raise DerpError.new("Can't add this player since he already has an active contract") if old_contract
      raise DerpError.new("Please pick a valid team to add that player to") unless @current_league.teams.any? {|t| t.id.to_s == params[:team_id]}
      move.old_contract = nil
      move.new_contract = Contract.create!(
        :team_id => params[:team_id],
        :player_id => params[:player_id],
        :first_year => Date.today.year,
        :value => 1, # el hacko. is this even right?
        :length => 1 # more hacko.
      )
      move.save!
    elsif params[:type] == 'drop'
      raise DerpError.new("Can't drop this player since he doesn't have an active contract") unless old_contract
      move.old_contract = old_contract
      move.new_contract = nil
      move.save!
    elsif params[:type] == 'trade'
      raise DerpError.new("Player doesn't have an active contract in this league") unless old_contract
      move.old_contract = old_contract
      move.new_contract = Contract.create!(
        :team_id => params[:team_id],
        :player_id => old_contract.player_id,
        :first_year => old_contract.first_year,
        :value => old_contract.value,
        :length => old_contract.length # more hacko.
      )
      move.save!
    else
      raise DerpError.new("Invalid move type")
    end
  rescue DerpError => ex
    add_flash(:error, false, ex.to_s)
  ensure
    redirect_to :back
  end

end