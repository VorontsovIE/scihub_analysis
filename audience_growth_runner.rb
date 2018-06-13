require 'fileutils'
require 'shellwords'
FileUtils.mkdir_p 'uid_dynamics'

Dir.glob('by_city/*').sort.each{|country_folder|
  city_fns = File.join(country_folder.shellescape, '*')
  country = File.basename(country_folder)
  output_file = File.join('uid_dynamics', "#{country}.tsv")
  puts "cat #{city_fns} | sort -t $'\\t' -k3,3n -k4,4n -k5,5n | ruby audience_growth.rb > #{output_file.shellescape}"
}
