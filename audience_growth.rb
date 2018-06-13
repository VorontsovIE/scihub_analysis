require 'set'

counts_by_yday = Hash.new(0)

uids_by_yday = Hash.new(0)
all_uids = Set.new
cumul_uids_by_yday = { -1 => 0 }

ips_by_yday = Hash.new(0)
all_ips = Set.new
cumul_ips_by_yday = { -1 => 0 }

$stdin.each_line.map{|l|
  row = l.chomp.split("\t")
  country, city,
        year, month, day, hour, min, sec, unnormed_wday, yday, dst,
        doi_prefix, ip, user, datetime, doi, lat, lng = *row
  if year == '2017'
    yday = yday.to_i
  elsif year == '2016'
    yday = 0
  elsif year == '2018'
    yday = 366
  end
  [yday, ip, user]
}.chunk{|yday, ip, uid|
  yday
}.each{|yday, triples|
  counts_by_yday[yday] = triples.size
  ips = triples.map{|t| t[1] }.uniq
  uids = triples.map{|t| t[2] }.uniq
  ips_by_yday[yday] = ips.size
  uids_by_yday[yday] = uids.size
  all_ips.merge(ips)
  all_uids.merge(uids)
  cumul_uids_by_yday[yday] = all_uids.size
  cumul_ips_by_yday[yday] = all_ips.size
}

# fill gaps in cumulative counts
last_met_cumul_uids = 0
(0..366).each{|yday|
  if cumul_uids_by_yday[yday]
    last_met_cumul_uids = cumul_uids_by_yday[yday]
  else
    cumul_uids_by_yday[yday] = last_met_cumul_uids
  end
}

last_met_cumul_ips = 0
(0..366).each{|yday|
  if cumul_ips_by_yday[yday]
    last_met_cumul_ips = cumul_ips_by_yday[yday]
  else
    cumul_ips_by_yday[yday] = last_met_cumul_ips
  end
}

header = [
  'yday', 'count',
  'num_uids', 'cumulative_num_uids', 'uids_growth',
  'num_ips', 'cumulative_num_ips', 'ips_growth',
]
puts header.join("\t")
(0..366).map{|yday|
  uids_growth = cumul_uids_by_yday[yday] - cumul_uids_by_yday[yday - 1]
  ips_growth = cumul_ips_by_yday[yday] - cumul_ips_by_yday[yday - 1]
  [
    yday, counts_by_yday[yday], 
    uids_by_yday[yday], cumul_uids_by_yday[yday], uids_growth,
    ips_by_yday[yday], cumul_ips_by_yday[yday], ips_growth,
  ]
}.each{|infos|
  puts infos.join("\t")
}
