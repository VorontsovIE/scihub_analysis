cell_size = Float(ARGV[0] || 0.5)
res = Hash.new{|h,lat| h[lat] = Hash.new(0) }
$stdin.each_line{|l|
  lat,lng = l.chomp.split("\t").last(2).map(&:to_f)
  lat_cell = (lat / cell_size).round
  lng_cell = (lng / cell_size).round
  res[lat_cell][lng_cell] += 1
}
puts ['lat', 'lng', 'count'].join("\t")
res.sort.each{|lat,h|
  h.sort.each{|lng,v|
    puts ['%0.1f' % (lat*cell_size), '%0.1f' % (lng*cell_size), v].join("\t")
  }
}
# puts ['x', *(-180*2..180*2).map{|lng| '%0.1f' % (lng*0.5) }].join("\t")
# (-90*2..90*2).each{|lat|

#   vals = (-180*2..180*2).map{|lng| res[lat][lng] }
#   puts ['%0.1f' % (lat * 0.5), *vals].join("\t")
# }
