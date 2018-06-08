require_relative 'heatmap'

class HeatmapCollection
  attr_reader :weektime10, :weektime60, :daytime10, :daytime60
  def initialize
    @weektime10 = Heatmap::Weektime10.new
    @weektime60 = Heatmap::Weektime60.new
    @daytime10 = Heatmap::Daytime10.new
    @daytime60 = Heatmap::Daytime60.new
  end

  def feed(time_info)
    [weektime10, weektime60, daytime10, daytime60].each{|heatmap|
      heatmap.feed(time_info)
    }
  end

  def feed_line(line)
    feed(timeinfo_from_line(line))
  end

  def timeinfo_from_line(line)
    row = line.chomp.split("\t")
    country, city,
      year, month, day, hour, min, sec, unnormed_wday, yday, dst,
      doi_prefix, ip, user, datetime, doi, lat, lng = *row
    Timeinfo.new(
      year: Integer(year), month: Integer(month), day: Integer(day),
      hour: Integer(hour), min: Integer(min), sec: Integer(sec),
      wday: (Integer(unnormed_wday) + 6) % 7, # `wday` starts from Monday - 0th day (unnormed_wday = 0 is Sunday)
      yday: Integer(yday),
      dst: Integer(dst)
    )
  end
end
