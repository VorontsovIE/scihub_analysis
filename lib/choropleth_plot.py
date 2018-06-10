import numpy as np
import pandas as pd
import plotly.graph_objs as go
from plotly.offline import iplot

import colorcet as cc
from colorscale_conversion import matplotlib_colorscale_to_plotly
CHOROPLETH_COLORSCALE = matplotlib_colorscale_to_plotly(cc.m_bgy_r, 256)
# CHOROPLETH_COLORSCALE = 'Reds'

def draw_choropleth_by_dataframe(df, title, filename=None):
    data = {
        'type': 'choropleth',
        'locations': df['country'], 'locationmode': 'country names',
        'z': df['value'],
        'text': df['country'],
        'colorscale': CHOROPLETH_COLORSCALE,
        'reversescale': False,
        'colorbar': {
            'title': None,
            'thickness': 10,
            'ticklen': 0,
            'tickfont': {'size': 16},
            'len': 0.8,
        },
    }

    layout = {
        'title': title,
        'titlefont': {'size': 24},
        'margin': {'l': 0, 't': 50, 'b': 0, 'r': 0, 'pad': 0,},
        'geo': {
            'showframe': False, 
            'projection': {'type':'Mercator'},
            'showcountries': True,
            'bgcolor': 'rgba(0,0,0,0)',
        },
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
    }
    choromap = go.Figure(data=[data], layout=layout)
    if filename:
        # don't fix height not to get large vertical pads around map
        iplot(choromap, validate=False, image_width=1280, image='png', filename=filename)#, image_height=1024
    else:
        iplot(choromap, validate=False, image_width=1280)#, image_height=1024

def choropleth_df(value_method, relevant_countries):
    pairs = [(country, value_method(country)) for country in relevant_countries]
    return pd.DataFrame(pairs, columns = ['country', 'value'])

def draw_choropleth(value_method, relevant_countries, title, filename=None):
    draw_choropleth_by_dataframe(choropleth_df(value_method, relevant_countries), title, filename)
