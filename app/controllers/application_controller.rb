class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_errors
  before_filter :reject_posts_by_nongods
  
  def reject_posts_by_nongods
    errors = []
    
    if !request.get?
      if [request.path_parameters[:controller], request.path_parameters[:action]] == ['application', 'login']
        # We're cool here
      elsif session[:user_id].blank?
        errors << "Gotta be logged in to do that, bro."
      elsif not (User.find session[:user_id]).god_mode
        errors << "You need GOD MODE to do that, man."
      end
    end

    if errors.count > 0
      errors.each { |e| add_error e }
      render :inline => '', :layout => true
    end
    
  end 
  
  def add_error(msg)
    flash[:errors] << msg
  end
  
  def add_warning(msg)
    flash[:warnings] << msg
  end
  
  def add_notice(msg)
    flash[:notices] << msg
  end
  
  def set_errors
    flash[:errors] ||= []
    flash[:warnings] ||= []
    flash[:notices] ||= []
  end
  
  def login
    users = User.where(:name => params[:name], :pw_hash => Digest::MD5.hexdigest(params[:password]))
    if users.count == 0
      add_error "User '#{params[:name]}' doesn't exist, or password is incorrect."
    elsif users.count > 1
      add_error "Lolwut, found multiple users with that name and password"
    else
      session[:user_id] = users.first.id
      add_notice "Logged in. Welcome, #{users.first.name}!"
    end
    
    render 'leagues/index'
  end
  
  def logout
    reset_session
    # set_errors # Has to happen after reset_session
    # add_notice "You are now logged out"
  end
  
end
