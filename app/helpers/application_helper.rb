module ApplicationHelper

  def god?
    puts "user: #{@current_user.inspect}"
    @current_user and @current_user.god_mode
  end

  def timespan_string(seconds_left)
      time_left_days = (seconds_left / (60*60*24)).to_i
      time_left_hours = ((seconds_left - time_left_days*60*60*24) / (60*60)).to_i
      time_left_minutes = ((seconds_left - time_left_days*60*60*24 - time_left_hours*60*60) / 60).to_i
      return "#{time_left_days} days, #{time_left_hours} hours, #{time_left_minutes} minutes"
  end

end
