module Enumerable
  def count_by(&block)
    self.each_with_object(Hash.new(0)){|obj, hsh| grp = yield obj; hsh[grp] += 1}
  end
end

def weekhour_repr(weekhour)
  wday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  "%s, %02d" % [wday[weekhour / 24], weekhour % 24]
end
# puts ['hour', '#IPs', '#users', 'users per IP', '#day-IPs', '#day-users', 'day-users per day-IP'].join("\t")
Record = Struct.new(:yday, :wday, :hour, :ip, :user) do
  def weekhour; wday*24 + hour; end
end

records = ARGF.each_line.map{|l|
  country, city, year, month, day, hour, min, sec, wday, yday, dst, doi_prefix, ip, user, datetime, doi, lat, lng = l.chomp.split("\t")
  Record.new(yday.to_i, (wday.to_i + 6) % 7, hour.to_i, ip, user)
}

# # Analyze num users per ip by week hour
# records.group_by(&:weekhour).map{|group_hour, group|
#   num_uniq_ips = group.map(&:ip).uniq.size
#   num_uniq_users = group.map(&:user).uniq.size
#   num_uniq_day_ips = group.map{|r| [r.yday, r.ip] }.uniq.size
#   num_uniq_day_users = group.map{|r| [r.yday, r.user] }.uniq.size
#   [
#     group_hour,
#     weekhour_repr(group_hour), 
#     # num_uniq_ips, num_uniq_users, num_uniq_ips == 0 ? -1 : num_uniq_users.to_f / num_uniq_ips ,
#     num_uniq_day_ips, num_uniq_day_users, num_uniq_day_ips == 0 ? -1 : num_uniq_day_users.to_f / num_uniq_day_ips,
#   ]
# }.sort.each{|infos|
#   puts infos.join("\t")
# }

# # Woring hours of different IPs
# puts ['ip','total', *(0...24*7).map{|x| weekhour_repr(x) }].join("\t")
puts ['ip', '#papers', '#users', 'papers per user', '#ydays', *(0...24).map{|x| "%02d:00" % x }].join("\t")
records.group_by(&:ip).sort_by{|ip, group|
  - group.size
}.first(1000).map{|ip, group|
  num_papers = group.size
  num_users = group.map(&:user).uniq.size
  nonzero_days = group.map(&:yday).uniq.size
  # [ip, group.size, group.count_by(&:weekhour).values_at(*(0...24*7).to_a)]
  [ip, num_papers, num_users, num_papers.to_f / num_users, nonzero_days, group.count_by(&:hour).values_at(*(0...24).to_a)]
}.each{|row| 
  puts row.join("\t")
}


# p records.group_by(&:user).map{|user, group|
#   group.size
# }.count_by(&:itself)

# records.group_by(&:user).sort_by{|user, group|
#   group.size
# }.reverse.first(10000).map{|user, group|
#   counts_by_yday = group.count_by(&:yday)
#   # puts [user, group.size, counts_by_yday.values.max, (1..366).count{|yday| counts_by_yday[yday].zero?}, *(1..366).map{|yday| counts_by_yday[yday] }].join("\t")
# }



# .map{|group_yday, group|
#   num_users_at_ip = group.group_by{|yday, hour, ip, user|
#     ip
#   }.map{|subgroup_ip, subgroup|
#     subgroup.map{|yday, hour, ip, user|
#       user
#     }.uniq.size
#   }.sort.reverse

#   num_ips_at_user = group.group_by{|yday, hour, ip, user|
#     user
#   }.map{|subgroup_user, subgroup|
#     subgroup.map{|yday, hour, ip, user|
#       ip
#     }.uniq.size
#   }.sort.reverse

#   # puts [group_yday, group_hour].join("\t")
#   # p num_users_at_ip
#   p num_ips_at_user
#   # num_uniq_ips = group.map{|yday, hour, ip, user| ip }.uniq.size
#   # num_uniq_users = group.map{|yday, hour, ip, user| user }.uniq.size
#   # num_uniq_day_ips = group.map{|yday, hour, ip, user| [yday,ip] }.uniq.size
#   # num_uniq_day_users = group.map{|yday, hour, ip, user| [yday,user] }.uniq.size
#   # [
#   #   group_hour, 
#   #   num_uniq_ips, num_uniq_users, num_uniq_ips == 0 ? -1 : num_uniq_users.to_f / num_uniq_ips ,
#   #   num_uniq_day_ips, num_uniq_day_users, num_uniq_day_ips == 0 ? -1 : num_uniq_day_users.to_f / num_uniq_day_ips,
#   # ]
# }.sort.each{|infos|
#   puts infos.join("\t")
# }


# # records.group_by{|yday, hour, ip, user|
# #   yday
# # }.map{|group_yday, group|
# #   ip_paper_counts = group.group_by{|yday, hour, ip, user| ip }.map{|subgroup_ip, subgroup| subgroup.size }.sort
# #   user_paper_counts = group.group_by{|yday, hour, ip, user| user }.map{|subgroup_user, subgroup| subgroup.size }.sort
# #   puts group_yday
# #   puts ip_paper_counts.inspect
# #   puts user_paper_counts.inspect
# # }
