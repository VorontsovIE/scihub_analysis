require 'tzinfo'

# we use midday, not midnight because clock is routinely shifted at night so moments for some midnights may be absent
def midday_by_yday(yday)
  Time.new(2017,1,1, 12,0,0) + (yday - 1)*3600*24
end

raise 'Specify timezone'  unless timezone = ARGV[0]
tz = TZInfo::Timezone.get(timezone)

(1..365).map{|yday|
  [yday, tz.period_for_local(midday_by_yday(yday)).std_offset]
}.chunk{|yday, offset|
  offset
}.map{|offset, pairs|
  [offset, pairs.map(&:first)]
}.map{|offset, ydays|
  period_range = [ydays.min, ydays.max].map{|yday|
    midday_by_yday(yday).to_date
  }
  [*period_range, offset]
}.each{|infos|
  puts infos.join("\t")
}
