from time import sleep
import time_counts
import plotly.graph_objs as go
from plotly.offline import iplot

def plot_daytime(places, filename=None, rescale=True, pull_down=False):
    layout = {
        'margin': {'b':80, 't': 0, 'l': 45},
        'legend': {'y' : 0.5, 'font': {'size': 20},},
        'font': {'size': 20},
        'yaxis': {
            'range': [0,1.05],
            'rangemode': 'tozero',
            'showline': True,
            'gridwidth': 1,
            'gridcolor': '#bdbdbd',
#             'showticklabels': False,
        },
        'xaxis': {
            'dtick': 24, # every 4 hours
            'showline': True,
            'gridwidth': 1,
            'gridcolor': '#bdbdbd',        
            'tickangle': 270,
        },
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
    }
    data = []
    for place in places:
        vals = time_counts.rates_daytime10_by_place[place]
        
        if pull_down:
            minval = min(vals)
            vals = [x - minval for x in vals]
        if rescale:
            maxval = max(vals)
            vals = [x*1.0 / maxval for x in vals]
        
        trend = go.Scatter(
            x = time_counts.DAYTIME10_HEADER,
            y = vals + [vals[0]], # 24:00 is the same as 00:00
            mode = 'lines',
            line = {'width': 5},
            name = ', '.join(place)
        )
        data.append(trend)

    fig = go.Figure(data=data, layout=layout)
    if filename:
        iplot(fig, image_width=1280, image_height=1024, image='png', filename=filename)
        sleep(1)
    else:
        iplot(fig, image_width=1280, image_height=1024)
