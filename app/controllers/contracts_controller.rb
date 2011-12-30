class ContractsController < ApplicationController
  @contract = nil
  
  def create
    
    @contract = Contract.create(
      :team_id => params[:team_id],
      :player_id => params[:player_id],
      :first_year => params[:first_year].presence || Date.today.year,
      :value => params[:value],
      :length => params[:length].presence || (params[:value].to_i/15).round # HACK
    )
    render :show
  end
  
  def update
    Contract.update(params[:id], params.reject { |k,v| ['_method', 'action', 'controller'].member? k })
    render :show
  end
  
  def show
    @contract ||= Contract.find(params[:id])
    render :json => contract.to_json
  end
  
end