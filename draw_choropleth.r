#!/usr/bin/env Rscript
library('rworldmap')
library('rworldxtra')
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Specify output file", call.=FALSE)
}

output_fn = args[1]
country_data = read.csv('stdin', sep='\t')
country_data$logCount = log10(country_data$count)
choropleth = joinCountryData2Map(country_data, joinCode = 'ISO3', nameJoinColumn = 'code', verbose = TRUE, mapResolution='high')
mapDevice('png', file=output_fn)
mapCountryData(choropleth, nameColumnToPlot = 'count', numCats=100,catMethod='quantiles')
dev.off()
