import os
from time import sleep
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


def renorm_heatmap(heatmap, renorm=True, outlier_threshold_coeff=4):
    heatmap = heatmap.copy(deep=True)
    title_suffixes = []
    if renorm:
        heatmap = heatmap.transpose()
        heatmap_sum_over_periods = np.sum(heatmap, axis=0)
        heatmap_sum_over_periods[ heatmap_sum_over_periods == 0 ] = 1.0
        heatmap = (heatmap * 1.0 / heatmap_sum_over_periods).transpose()
        title_suffixes.append('weeks renormed')
    if outlier_threshold_coeff:
        heatmap_max = outlier_threshold_coeff * np.median(heatmap)
        title_suffixes.append('outliers filtered')
        heatmap[heatmap > heatmap_max] = heatmap_max
    return (heatmap, title_suffixes)

# mode can be one of: week10 / week60 / day10 / day60
def plot_heatmap(heatmap_filename, mode='week10', 
                 renorm=True, outlier_threshold_coeff=4, 
                 aggregation_mode='barplot',
                 title=None, output_filename=None):
    if aggregation_mode not in [None, 'barplot', 'filled_area', 'line']:
        raise 'Unknown aggregation mode'
    original_heatmap = pd.read_csv(heatmap_filename, sep='\t')
    original_heatmap = original_heatmap.iloc[::-1] # the first week of a year goes at image top
    cell_text = [["num downloads: "+str(el) for el in row] for row in original_heatmap.values]
    
    heatmap, title_suffixes = renorm_heatmap(original_heatmap, renorm, outlier_threshold_coeff)
    
    if not title:
        title = os.path.splitext(os.path.basename(heatmap_filename))[0]
        if len(title_suffixes) > 0:
            title += ' (' + ', '.join(title_suffixes) + ')'
    
    if mode not in ['week10', 'week60', 'day10', 'day60']:
        raise 'Unknown mode'
        
    if mode.startswith('week'):
        bottom_margin = 135
    elif mode.startswith('day'):
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
        'margin': {'l':185, 't': 50, 'b': bottom_margin},
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
        'xaxis': {
            'dtick': dtick, 'ticklen': 0, 'tickangle': 270, 'tickfont':{'size': 20},
            'showgrid': False,
        },
        'yaxis': {
            'dtick': 1, 'tickfont': {'size': 20},
            'showgrid': False,
        },
        
    }
    week_ranges = [human_week(week) for week in range(heatmap.shape[0])]
    
    heatmap_data = {
        'type': 'heatmap', 'colorscale': HEATMAP_COLORSCALE,
        'name': 'Num downloads', 'text': cell_text, 'hoverinfo': 'all',
        'z': heatmap.values,
        'x': list(heatmap.keys()),
        'y': list(reversed(week_ranges)),
        'colorbar': { 'thickness': 10, 'ticklen': 0, 'tickfont': {'size': 16}, },
        'xaxis': 'x', 'xaxis': 'y',
    }
    data = [heatmap_data]
    
    if aggregation_mode:
        x_split = 0.9
        y_split = 0.9
        
        # heatmap (main axes)
        layout['xaxis'].update({'domain': [0, x_split]})
        layout['yaxis'].update({'domain': [0, y_split]})
        layout.update({         
            # total by week (common y axis with heatmap)
            'xaxis2': { 'domain': [x_split, 1], 'rangemode': 'tozero', },
            # total by time (common x axis with heatmap)
            'yaxis3': { 'domain': [y_split, 1], 'rangemode': 'tozero', },
        })
        
        totals_by_week = original_heatmap.sum(axis=1).values
        totals_by_time = original_heatmap.sum(axis=0).values
        total_by_week_data = {
            'name': 'total in period', 'showlegend': False,
            'x': totals_by_week,
            'y': list(reversed(week_ranges)),
            'xaxis': 'x2', 'yaxis': 'y',
        }

        total_by_time_data = {
            'name': 'total at time', 'showlegend': False,
            'x': list(heatmap.keys()),
            'y': totals_by_time,        
            'xaxis': 'x', 'yaxis': 'y3',
        }
        
        if aggregation_mode == 'line':
            total_by_week_data.update({'type': 'scatter'})
            total_by_time_data.update({'type': 'scatter'})
        elif aggregation_mode == 'barplot':
            total_by_week_data.update({'type': 'bar', 'width': 0.95, 'orientation': 'h', 'marker':{'color': totals_by_week}})
            total_by_time_data.update({'type': 'bar', 'width': 0.95, 'marker':{'color': totals_by_time}})
        elif aggregation_mode == 'filled_area':
            total_by_week_data.update({'type': 'scatter', 'fill': 'tozerox'})
            total_by_time_data.update({'type': 'scatter', 'fill': 'tozeroy'})
        
        data += [total_by_week_data, total_by_time_data]
    
    fig = go.Figure(data=data, layout=layout)
    if output_filename:
        iplot(fig, image_width=1280, image_height=1024, image='png', filename=output_filename)
        sleep(1) # it's typical that image is downloaded before it was fully rendered
    else:
        iplot(fig, image_width=1280, image_height=1024)
