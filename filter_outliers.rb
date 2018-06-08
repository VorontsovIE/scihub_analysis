quantiles = [0.25, 0.5, 0.75, 1.0]
count_rows = File.readlines('counts/country/yday.tsv').drop(1).map{|l|
  country, total, *counts = l.chomp.split("\t")
  [country, Integer(total), counts.map{|x|Integer(x)}]
}

def median(arr)
  arr.sort[arr.size / 2]
end
def count_quantiles(arr, quantiles)
  arr_sorted = arr.sort
  quantiles.map{|x|
    ind = ((arr.size - 1) * x).round
    arr_sorted[ind]
  }
end

count_rows.each{|country, total, counts|
  qs = count_quantiles(counts, quantiles)
  median_cnt = median(counts)
  # fractions_above = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map{|q|
  #   counts.select{|cnt| cnt <= q*median_cnt }.size
  # }
  infos = [country, total, median_cnt,
    #qs, fractions_above
  ]
  puts infos.join("\t")
  # puts [country, median_cnt.zero? ? '-1' : (counts.max.to_f / median_cnt)].join("\t")
}