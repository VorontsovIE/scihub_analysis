#!/usr/bin/env Rscript
library('rworldmap')
library('rworldxtra')
library('spam')
library('fields')
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Specify output file", call.=FALSE)
}

output_fn = args[1]
data_rows = read.csv(file='stdin', sep='\t', header=TRUE)
data_rows = data_rows[order(data_rows['count']),]
mapDevice('png', file=output_fn)
mapBubbles( data_rows, nameX='lng', nameY='lat', 
	nameZSize='count', nameZColour='count',
	colourPalette = "topo", numCats=100, catMethod='logFixedWidth', symbolSize=0.3,
	addColourLegend=FALSE, addLegend=FALSE, main='', mapResolution='high')
dev.off()
