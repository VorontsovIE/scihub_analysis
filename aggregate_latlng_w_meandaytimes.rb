def quantiles(arr, alphas)
  sorted_arr = arr.sort
  alphas.map{|alpha| sorted_arr[ (alpha * (arr.size - 1)).round ] }
end

total_by_city = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2] = 0 } }
latlng_by_city = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2] = [nil, nil] } }
File.readlines('results_secondary/city_center_coords.tsv').map{|l|
  country, city, total, lat, lng = l.chomp.split("\t")
  total_by_city[country][city] = total
  latlng_by_city[country][city] = [lat, lng]
}

puts ['country', 'city', 'total', 'lat', 'lng', *(1..9).map{|i| "q#{10*i}" }].join("\t")
File.open('counts/city/mean_daytime.tsv'){|f|
  f.readline # drop header
  f.each_line{|l|
    country, city, _total, *mean_daytimes = l.chomp.split("\t")
    mean_daytimes.map!{|x| Float(x) }
    alphas = (1..9).map{|i| i / 10.0}
    mean_daytime_quantiles = quantiles(mean_daytimes, alphas)
    puts [country, city, total_by_city[country][city], *latlng_by_city[country][city], *mean_daytime_quantiles].join("\t")
  }
}
