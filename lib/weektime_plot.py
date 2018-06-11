from time import sleep
import time_counts
import plotly.graph_objs as go
from plotly.offline import iplot

def plot_weektime(places, filename=None, mode='weektime60', rescale=True, pull_down=False):
    if mode not in ['weektime10', 'weektime60']:
        raise 'Unknown mode'
    
    if mode == 'weektime10':
        dtick = 24 # every 4 hours
        x_header = time_counts.WEEKTIME10_HEADER
    elif mode == 'weektime60':
        dtick = 4 # every 4 hours
        x_header = time_counts.WEEKTIME60_HEADER
    
    layout = {
        'margin': {'b':120, 't': 0, 'l': 40},
        'legend': {'y' : 0.5, 'font': {'size': 20},},
        'font': {'size': 18},
        'yaxis': {
            'range': [0,1.05],
            'rangemode': 'tozero',
            'showline': True,
            'gridwidth': 1,
            'gridcolor': '#bdbdbd',
            'showticklabels': True,
        },
        'xaxis': {
            'dtick': dtick, # every 4 hours
            'showline': False,
            'gridwidth': 1,
            'gridcolor': '#bdbdbd',        
            'tickangle': 270,
        },
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
    }
    data = []
    for place in places:
        if mode == 'weektime10':
            vals = time_counts.rates_weektime10_by_place[place]
        elif mode == 'weektime60':
            vals = time_counts.rates_weektime60_by_place[place]

        if pull_down:
            minval = min(vals)
            vals = [x - minval for x in vals]
        if rescale:
            maxval = max(vals)
            vals = [x*1.0 / maxval for x in vals]
        
        trend = go.Scatter(
            x = x_header,
            y = vals + [vals[0]], # Sun 24:00 is the same as Mon 00:00
            mode = 'lines',
            line = {'width': 5},
            name = ', '.join(place)
        )
        data.append(trend)
    
    # Draw borderline of different colors for different weekdays
    weekday_names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday','Friday', 'Saturday', 'Sunday']
    rainbow_colors = ['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Violet']
    for wday in range(7):
        if mode == 'weektime10':
            xs = [time_counts.WEEKTIME10_HEADER[wday*24*6 + daytime10] for daytime10 in range(24*6 + 1)]
            ys = [0]*(24*6 + 1)
        elif mode == 'weektime60':
            xs = [time_counts.WEEKTIME60_HEADER[wday*24 + daytime60] for daytime60 in range(24 + 1)]
            ys = [0]*(24 + 1)
        
        data.append({'mode':'lines', 'name': weekday_names[wday], 'showlegend': False,
                     'line': {'width': 10, 'color': rainbow_colors[wday]},
                     'x': xs, 'y': ys,
                    })
        
    fig = go.Figure(data=data, layout=layout)
    if filename:
        iplot(fig, image_width=1280, image_height=1024, image='png', filename=filename)
        sleep(1)
    else:
        iplot(fig, image_width=1280, image_height=1024)
