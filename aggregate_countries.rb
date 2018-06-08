require 'fileutils'
FileUtils.mkdir_p 'counts/country/'
FileUtils.mkdir_p 'rates/country/'

def aggregate_contries(counts_input_fn, counts_output_fn, rates_output_fn)
  total_by_country = Hash.new(0)
  count_sums_by_country = {}
  header = nil
  File.open(counts_input_fn) do |f|
    header = f.readline.chomp.split("\t")
    f.each_line{|l|
      row = l.chomp.split("\t")
      country,city,total,*counts = *row
      total = Integer(total)
      counts = counts.map{|x| Integer(x) }
      total_by_country[country] += total
      if count_sums_by_country.has_key?(country)
        count_sums_by_country[country] = count_sums_by_country[country].zip(counts).map{|x,y| x+y}
      else
        count_sums_by_country[country] = counts
      end
    }
  end

  result_by_country = count_sums_by_country

  File.open(counts_output_fn, 'w'){|fw|
    fw.puts ['country','total', *header.drop(3)].join("\t")
    result_by_country.sort.each{|country, result_row|
      fw.puts [country, total_by_country[country], *result_row].join("\t")
    }
  }
  File.open(rates_output_fn, 'w'){|fw|
    fw.puts ['country','total', *header.drop(3)].join("\t")
    result_by_country.sort.each{|country, result_row|
      total = total_by_country[country]
      fw.puts [country, total, *result_row.map{|x| (x.to_f / total).round(5) }].join("\t")
    }
  }
end


def aggregated_mean_daytime(mean_daytime_input_fn, yday_counts_input_fn, output_fn)
  yday_counts_by_zone = File.readlines(yday_counts_input_fn).drop(1).map{|l|
    country, city, total, *counts = l.chomp.split("\t")
    zone = [country, city]
    [zone, counts.map(&:to_i)]
  }.to_h

  yday_counts_by_country = yday_counts_by_zone.group_by{|(country, city), counts|
    country
  }.map{|country, zone_count_pairs|
    country_yday_counts = zone_count_pairs.map{|zone, counts| counts }.transpose.map(&:sum)
    [country, country_yday_counts]
  }.to_h

  weighted_sums_by_country = {}
  header = nil
  File.open(mean_daytime_input_fn) do |f|
    header = f.readline.chomp.split("\t")
    f.each_line{|l|
      row = l.chomp.split("\t")
      country,city,*counts = *row
      counts = counts.map(&:to_i)
      zone = [country, city]
      weighted_counts_for_city = counts.zip(yday_counts_by_zone[zone]).map{|count, city_yday_count| count * city_yday_count }
      if weighted_sums_by_country.has_key?(country)
        weighted_sums_by_country[country] = weighted_sums_by_country[country].zip(weighted_counts_for_city).map{|x,y| x + y }
      else
        weighted_sums_by_country[country] = weighted_counts_for_city
      end
    }
  end

  File.open(output_fn, 'w'){|fw|
    fw.puts ['country', *header.drop(2)].join("\t")

    weighted_sums_by_country.keys.sort.each{|country|
      weighted_sums = weighted_sums_by_country[country]
      yday_counts = yday_counts_by_country[country]
      weighted_mean_sum = weighted_sums.zip(yday_counts).map{|weighted_sum, yday_count| (yday_count == 0) ? 0 : weighted_sum / yday_count }
      fw.puts [country, *weighted_mean_sum].join("\t")
    }
  }
end

aggregate_contries('counts/city/yday.tsv','counts/country/yday.tsv','rates/country/yday.tsv')
aggregate_contries('counts/city/wday.tsv','counts/country/wday.tsv','rates/country/wday.tsv')
aggregate_contries('counts/city/daytime_10.tsv','counts/country/daytime_10.tsv','rates/country/daytime_10.tsv')
aggregate_contries('counts/city/hour.tsv','counts/country/hour.tsv','rates/country/hour.tsv')
aggregate_contries('counts/city/weekhour.tsv','counts/country/weekhour.tsv','rates/country/weekhour.tsv')
aggregate_contries('counts/city/weekhour_10.tsv','counts/country/weekhour_10.tsv','rates/country/weekhour_10.tsv')
aggregate_contries('counts/city/doi_prefix.tsv','counts/country/doi_prefix.tsv','rates/country/doi_prefix.tsv')

aggregated_mean_daytime('counts/city/mean_daytime.tsv', 'counts/city/yday.tsv', 'counts/country/mean_daytime.tsv')
