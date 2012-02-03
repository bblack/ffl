class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  before_filter :reject_posts_by_nongods
  
  def set_current_user
    if session[:user_id].nil?
      @current_user = nil
    else
      @current_user = User.find(session[:user_id])
    end
  end
  
  def reject_posts_by_nongods
    errors = []
    
    if !request.get?
      if [['application', 'login'], ['users', 'create']].member? [request.path_parameters[:controller], request.path_parameters[:action]]
        # We're cool here
      elsif session[:user_id].blank?
        errors << "Gotta be logged in to do that, bro."
      elsif not @current_user.god_mode
        errors << "You need GOD MODE to do that, man."
      end
    end

    if errors.count > 0
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
    users = User.where(:name => params[:name], :pw_hash => Digest::MD5.hexdigest(params[:password]))
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
