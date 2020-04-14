import datetime
from os.path import dirname, join

import pandas as pd

from bokeh.io import curdoc
from bokeh.layouts import column, row
from bokeh.models import ColumnDataSource, DataRange1d, Select
from bokeh.palettes import Blues4
from bokeh.plotting import figure

CHANNEL_NAMES = ["Water", "Rainfall"]


def make_plot(source, title):
    plot = figure(x_axis_type="datetime", plot_width=800, plot_height=400, 
                  tools="", toolbar_location=None)
    plot.title.text = title

    return plot


def update_station_list(attrname, old, new):
    print(attrname, old, new)


def update_plot(attrname, old, new):
    print(attrname, old, new)


channel_select = Select(
    value='Water', title='Channel type', options=CHANNEL_NAMES)
stations_select = Select(value='', title='Stations', options=['Discrete', 'Smoothed'])

plot = make_plot('source', "Stations")

channel_select.on_change('value', update_station_list)
stations_select.on_change('value', update_plot)

controls = column(channel_select, stations_select)

curdoc().add_root(row(plot, controls))
curdoc().title = "Channel data"
