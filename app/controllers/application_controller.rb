class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery
  before_filter :set_current_user
  # before_filter :brian_only_mode
  before_filter :reject_posts_by_nongods
  before_filter :reject_posts_unless_logged_in
  after_filter :write_header_user

  def app
    render :app, :layout => false
  end

  def set_current_user
    if session[:user_id].nil?
      @current_user = nil
    else
      @current_user = User.find(session[:user_id])
    end
  end

  def write_header_user
    response.headers['x-user'] = @current_user.to_json(only: [:id, :name])
  end

  def change_current_league(new_league_id)
    @current_league = League.includes(:rfa_periods).find(new_league_id)
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
    unless god? or [['application', 'login'], ['application', 'logout'], ['application', 'index']].member?([params[:controller], params[:action]])
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
        errors << @current_user
      end
    end

    if errors.any?
      respond_to do |format|
        format.html do
          errors.each { |e| add_flash :error, false, e }
          redirect_to :back
        end
        format.json { render status: 500, json: {errors: errors} }
      end
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
      err = "User '#{params[:name]}' doesn't exist, or password is incorrect."
    elsif users.count > 1
      err = "Lolwut, found multiple users with that name and password"
    else
      user = users.first
      session[:user_id] = user.id
    end

    respond_to do |format|
      format.html do
        if err
          add_flash :error, false, err
        else
          add_flash :notice, false, "Welcome #{users.first.name}!"
        end

        redirect_to :back
      end

      format.json do
        @current_user = user
        write_header_user
        render json: nil
      end
    end
  end

  def logout
    reset_session
    @current_user = nil
    respond_to do |format|
      format.html do
        add_flash :notice, false, "You are now logged out"
        redirect_to :action => 'index'
      end
      format.json { render status: 200, json: nil }
    end
  end

end
