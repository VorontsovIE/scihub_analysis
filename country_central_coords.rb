country_dirnames = Dir.glob('by_city/*').select{|fn| File.directory?(fn) }.map{|fn| File.basename(fn) }.sort

coord_infos = country_dirnames.map{|country_dirname|
  country = nil
  city_coords = Dir.glob("by_city/#{country_dirname}/*.tsv").sort.map{|fn|
    city = nil
    coords_list = File.open(fn){|f|
      country, city = f.readline.split("\t",3)
      f.rewind
      f.each_line.lazy.map{|l|
        l.chomp!
        row = l.split("\t")
        lat,lng = row[16], row[17]
        [lat, lng]
      }.reject{|lat,lng|
        lat == 'N/A'
      }.map{|lat,lng| 
        [Float(lat),Float(lng)]
      }.force
    }
    next nil  if coords_list.empty?      

    lats, lngs = coords_list.transpose
    city_total = lats.size
    mean_lat = lats.sum / city_total
    mean_lng = lngs.sum / city_total
    [country, city, city_total, mean_lat, mean_lng]
  }.compact

  next nil  if city_coords.empty?
  # city_coords.each{|country, city, total, mean_lat, mean_lng| puts [country, city, total, mean_lat, mean_lng].join("\t") }
  country_total, country_sum_lat, country_sum_lng = city_coords.map{|country, city, total, mean_lat, mean_lng|
    [total, mean_lat * total, mean_lng * total]
  }.transpose.map(&:sum)#.tap{|x| p [country, coords_list.size, x]; }
  country_coords = [country, country_total,  country_sum_lat.to_f / country_total, country_sum_lng.to_f / country_total]
  [country_coords, city_coords]
}.compact

country_coords = coord_infos.map(&:first)
city_coords = coord_infos.flat_map(&:last)
File.open('results_secondary/country_center_coords.tsv', 'w') {|fw| country_coords.each{|row| fw.puts row.join("\t") } }
File.open('results_secondary/city_center_coords.tsv', 'w') {|fw| city_coords.each{|row| fw.puts row.join("\t") } }
