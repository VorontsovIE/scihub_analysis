require_relative 'lib/heatmap_collection'

multi_heatmap = HeatmapCollection.new
$stdin.each_line{|l|
  multi_heatmap.feed_line(l)
}

raise 'Specify mode (one of all/weektime10/weektime60/daytime10/daytime60)'  unless mode = ARGV[0]
if mode == 'all'
  raise 'Specify output (base) filename'  unless output_filename = ARGV[1]
end

case mode
when 'all'
  dirname = File.dirname(output_filename)
  basename = File.basename(output_filename)
  File.open(File.join(dirname, "#{basename}_weektime10.tsv"), 'w'){|fw|
    multi_heatmap.weektime10.print(output_stream: fw)
  }
  File.open(File.join(dirname, "#{basename}_weektime60.tsv"), 'w'){|fw|
    multi_heatmap.weektime60.print(output_stream: fw)
  }
  File.open(File.join(dirname, "#{basename}_daytime10.tsv"), 'w'){|fw|
    multi_heatmap.daytime10.print(output_stream: fw)
  }
  File.open(File.join(dirname, "#{basename}_daytime60.tsv"), 'w'){|fw|
    multi_heatmap.daytime60.print(output_stream: fw)
  }
when 'weektime10'
  multi_heatmap.weektime10.print
when 'weektime60'
  multi_heatmap.weektime60.print
when 'daytime10'
  multi_heatmap.daytime10.print
when 'daytime60'
  multi_heatmap.daytime60.print
else
  raise 'Unknown mode'
end
