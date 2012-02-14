class DateRange
  attr_accessor :start, :stop
  
  def initialize(start, stop)
    [start, stop].each do |d|
      unless d.nil? || d.acts_like_time?
        raise StandardError.new("DateRange must be passed either nils or things that act like Time")
      end
    end
    
    @start = start
    @stop = stop
  end
  
  def strftime(time)
    time.strftime "%b %e \u2019%y (%l#{":#{@start.min}" if @start.min != 0} %p %Z)"
  end
  
  def start_s
    @start.nil? ? "Beginning of time" : strftime(@start)
  end
  
  def stop_s
    @stop.nil? ? "End of time" : strftime(@stop)
  end
  
  def to_s
    "#{start_s} to #{stop_s}"
  end
  
end