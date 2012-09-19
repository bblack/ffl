class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery
  before_filter :set_current_user
  before_filter :set_current_league
  before_filter :brian_only_mode
  before_filter :reject_posts_by_nongods
  before_filter :reject_posts_unless_logged_in
  
  def set_current_user
    if session[:user_id].nil?
      @current_user = nil
    else
      @current_user = User.find(session[:user_id])
    end
  end
  
  def set_current_league
    if session[:league_id].nil?
      @current_league = nil
    else
      @current_league = League.includes(:rfa_periods).find(session[:league_id])
    end
  end

  def change_current_league(new_league_id)
    league = League.where(:id => new_league_id).first

    if league.nil?
      session[:league_id] = nil
      add_flash :warning, true, "You are not browsing a league anymore"
    elsif session[:league_id] != league.id
      session[:league_id] = league.id
      add_flash :notice, true, "You are now browsing league '#{league.name}'"
    end
    
    set_current_league()
  end
  
  def reject_posts_unless_logged_in
    errors = []
    
    if not request.get?
      if [
        ['application', 'login'],
        ['users', 'create']
      ].member? [request.path_parameters[:controller], request.path_parameters[:action]]
        # We're cool here
      elsif @current_user.nil?
        errors << "Gotta be logged in to do that, bro"
      end
    end
    
    if errors.any?
      errors.each { |e| add_flash :error, false, e }
      redirect_to :back
    end
  end

  def brian_only_mode
    unless brian? or [['application', 'login'], ['application', 'index']].member?([params[:controller], params[:action]])
      add_flash(:error, false, 'Nope.') and redirect_to '/'
    end
  end
  
  def reject_posts_by_nongods
    errors = []
    
    if !request.get?
      if [
        ['application', 'login'],
        ['users', 'create'],
        ['rfa_bids', 'create'],
        ['rfa_decisions', 'create']
      ].member? [request.path_parameters[:controller], request.path_parameters[:action]]
        # We're cool here
      elsif not god?
        errors << "You need GOD MODE to do that, man."
      end
    end

    if errors.any?
      errors.each { |e| add_flash :error, false, e }
      redirect_to :back
    end
  end 
  
  def add_flash(category, now, msg)
    if not [:error, :warning, :notice].member? category
      raise "#{category} is not an acceptable flash category" 
    end
    
    if now
      flash.now[category] ||= []
      flash.now[category] << msg
    else
      flash[category] ||= []
      flash[category] << msg
    end
  end
  
  def login
    users = User.where("lower(name) = lower(?) and pw_hash = ?", params[:name], Digest::MD5.hexdigest(params[:password]))
    if users.count == 0
      add_flash :error, false, "User '#{params[:name]}' doesn't exist, or password is incorrect."
    elsif users.count > 1
      add_flash :error, false, "Lolwut, found multiple users with that name and password"
    else
      session[:user_id] = users.first.id
      add_flash :notice, false, "Welcome #{users.first.name}!"
    end
    redirect_to :back
  end
  
  def logout
    reset_session
    add_flash :notice, false, "You are now logged out"
    redirect_to :action => 'index'
  end
  
end
