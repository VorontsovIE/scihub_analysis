require 'fileutils'

fw = nil
prev_country, prev_city = false,false
FileUtils.mkdir_p 'by_city'
ARGF.each_line{|l|
  row = l.chomp.split("\t")
  country, city = row.first(2)
  if (city != prev_city) || (country != prev_country)
    fw.close  if fw
    prev_country, prev_city = country, city
    country_escaped, city_escaped = [country, city].map{|x| x.gsub('/', '_')}
    folder = File.join('by_city/', country_escaped)
    FileUtils.mkdir_p(folder)
    fw = File.open(File.join(folder, "#{city_escaped}.tsv"), 'w')
  end  
  fw.puts l
}
fw.close
