WDAY_BY_IDX = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
Timeinfo = Struct.new(:year, :month, :day, :hour, :min, :sec, :wday, :yday, :dst,  keyword_init: true)

# Heatmap aggregates a matrix `PERIOD x TIME`
# Default period is a week.
# Time aggregates data of that period in custom bins. Bins can represent e.g.
# * a certain hour summed over all weekdays (daytime_60)
# * a certain 10-minute interval in a certain weekday (weektime_10)
class Heatmap
  def initialize
    @counts = Hash.new{|hsh, period| hsh[period] = Hash.new(0) }
  end

  def feed(time_info)
    @counts[ period_bin(time_info) ][ time_bin(time_info) ] += 1
  end
  
  # week is a default period
  def period_bins_range; 0 ... (366/7); end
  def period_bin(time_info); (time_info.yday - 1) / 7; end 
  
  # any aggregates over period. E.g. (a)each day along period or (b)average day along period
  # should be redefined in subclasses
  def time_bins_range; raise NotImplementedError; end
  def time_bin(time_info); raise NotImplementedError; end
  
  
  def heatmap_matrix
    period_bins_range.map{|period|
      time_bins_range.map{|in_period_time|
        @counts[period][in_period_time]
      }
    }
  end
  def human_readable_time(in_period_time); raise NotImplementedError; end
  def in_period_header
    time_bins_range.map{|in_period_time|
      human_readable_time(in_period_time)
    }
  end
  def print(output_stream: $stderr)
    output_stream.puts in_period_header.join("\t")
    heatmap_matrix.each{|row|
      output_stream.puts row.join("\t")
    }
  end
end

# week splitted into 10-minute-long periods (6 periods per hour)
class Heatmap::Weektime10 < Heatmap
  def time_bin(tm)
    6 * (tm.wday * 24 + tm.hour) + (tm.min / 10)
  end
  def time_bins_range
    0...6*24*7
  end
  def human_readable_time(weektime_10)
      wday = weektime_10 / (6 * 24)
      daytime_10 = weektime_10 % (6 * 24)
      hour = daytime_10 / 6
      minute = 10 * (daytime_10 % 6)
      "%s, %02d:%02d" % [WDAY_BY_IDX[wday], hour, minute]
  end
end

# week splitted into hours
class Heatmap::Weektime60 < Heatmap
  def time_bin(tm)
    tm.wday * 24 + tm.hour
  end
  def time_bins_range
    0...24*7
  end
  def human_readable_time(weektime_60)
    wday = weektime_60 / 24
    hour = weektime_60 % 24
    "%s, %02d:00" % [WDAY_BY_IDX[wday], hour]
  end
end

# day splitted into 10-minute-long periods (6 periods per hour)
class Heatmap::Daytime10 < Heatmap
  def time_bin(tm)
    6 * tm.hour + (tm.min / 10)    
  end
  def time_bins_range
    0...6*24
  end
  def human_readable_time(daytime_10)
    hour = daytime_10 / 6
    minute = (daytime_10 % 6) * 10
    "%02d:%02d" % [hour, minute]
  end
end

# day splitted into hours
class Heatmap::Daytime60 < Heatmap
  def time_bin(tm)
    tm.hour
  end
  def time_bins_range
    0...24
  end
  def human_readable_time(hour)
    "%02d:00" % [hour]
  end
end
