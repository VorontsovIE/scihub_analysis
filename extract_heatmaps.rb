require_relative 'lib/heatmap_collection'
require 'fileutils'
FileUtils.mkdir_p 'heatmaps/daytime10/'
FileUtils.mkdir_p 'heatmaps/daytime60/'
FileUtils.mkdir_p 'heatmaps/weektime10/'
FileUtils.mkdir_p 'heatmaps/weektime60/'

country_folders = Dir.glob('by_city/*').select{|fn| File.directory?(fn) }

country_folders.each do |country_folder|
  multi_heatmap = HeatmapCollection.new

  city_files = Dir.glob(File.join(country_folder,'*.tsv')).sort
  city_files.each do |fn|
    $stderr.puts(fn)
    File.open(fn) do |f|
      f.each_line{|l|
        multi_heatmap.feed_line(l)
      }
    end
  end

  country = File.basename(country_folder)
  File.open("heatmaps/weektime10/#{country}.tsv", 'w'){|fw|
    multi_heatmap.weektime10.print(output_stream: fw)
  }
  File.open("heatmaps/weektime60/#{country}.tsv", 'w'){|fw|
    multi_heatmap.weektime60.print(output_stream: fw)
  }
  File.open("heatmaps/daytime10/#{country}.tsv", 'w'){|fw|
    multi_heatmap.daytime10.print(output_stream: fw)
  }
  File.open("heatmaps/daytime60/#{country}.tsv", 'w'){|fw|
    multi_heatmap.daytime60.print(output_stream: fw)
  }
end
