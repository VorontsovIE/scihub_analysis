import os
import time, datetime
import numpy as np
import pandas as pd
import plotly.graph_objs as go
from plotly.offline import iplot

import colorcet as cc
from colorscale_conversion import matplotlib_colorscale_to_plotly
HEATMAP_COLORSCALE = matplotlib_colorscale_to_plotly(cc.m_diverging_rainbow_bgymr_45_85_c67, 256)


def date_by_yday(yday):
    return datetime.datetime(2017,1,1) + datetime.timedelta(days = yday-1)

# Our weeks always start at Monday, so the very first week can start in 2016
for yday_attempt in [1,0,-1,-2,-3,-4,-5]:
    if date_by_yday(yday_attempt).weekday() == 0:
        YDAY_OF_FIRST_DAY = yday_attempt

# `26 Dec - 01 Jan`, `02 Jan - 08 Jan`, etc
def human_week(week):
    from_day = date_by_yday(YDAY_OF_FIRST_DAY + week*7)
    to_day = date_by_yday(YDAY_OF_FIRST_DAY + (week + 1)*7 - 1)
    return "%s - %s" % (from_day.strftime('%d %b'), to_day.strftime('%d %b'))

# mode can be one of: week10 / week60 / day10 / day60
def heatmap(heatmap_filename, title=None, mode='week10', renorm=True, outlier_threshold_coeff=4, output_filename=None):
    spectra = pd.read_csv(heatmap_filename, sep='\t')
    title_suffixes = []
    if renorm:
        spectra = spectra.transpose()
        spectra_sum_over_periods = np.sum(spectra, axis=0)
        spectra_sum_over_periods[ spectra_sum_over_periods == 0 ] = 1.0
        spectra = (spectra * 1.0 / spectra_sum_over_periods).transpose()
        title_suffixes.append('weeks renormed')
    if outlier_threshold_coeff:
        spectra_max = outlier_threshold_coeff * np.median(spectra)
        title_suffixes.append('outliers filtered')
        spectra[spectra > spectra_max] = spectra_max
    if not title:
        title = os.path.splitext(os.path.basename(heatmap_filename))[0]
        if len(title_suffixes) > 0:
            title += '(' + ', '.join(title_suffixes) + ')'
    
    spectra = spectra.iloc[::-1] # the first week of a year goes at image top
    if mode not in ['week10', 'week60', 'day10', 'day60']:
        raise 'Unknown mode'
        
    if mode.startswith('week'):
        x_header = list(spectra.keys()) + ['Sun, 24:00']
        bottom_margin = 135
    elif mode.startswith('day'):
        x_header = list(spectra.keys()) + ['24:00']
        bottom_margin = 85
    
    if mode == 'week10': # each 4 hours
        dtick = 24
    elif mode == 'week60': # each 4 hours
        dtick = 4
    elif mode == 'day10': # each hour
        dtick = 6
    elif mode == 'day60': # each hour
        dtick = 1
    
    layout = {
        'title': title,
        'titlefont': {'size': 20},
        'margin': {'l':185, 'b': bottom_margin, 't': 50},
        'yaxis': { 'dtick': 1, 'tickfont': {'size': 20} },
        'xaxis': { 'dtick': dtick, 'ticklen': 0, 'tickangle': 270, 'tickfont':{'size': 20} },
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
    }
    week_ranges = [human_week(week) for week in range(spectra.shape[0])]
    data = [{
        'type': 'heatmap', 'colorscale': HEATMAP_COLORSCALE,
        'z':  np.hstack([spectra.values, spectra.values[:,0].reshape(-1,1)]),
        'x': x_header,
        'y': list(reversed(week_ranges)),
        'colorbar': { 'thickness': 10, 'ticklen': 0, 'tickfont': {'size': 16} },
    }]
    fig = go.Figure(data=data, layout=layout)
    if output_filename:
        iplot(fig, image_width=1280, image_height=1024, image='png', filename=output_filename)
    else:
        iplot(fig, image_width=1280, image_height=1024)
