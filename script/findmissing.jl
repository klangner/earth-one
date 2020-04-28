# Find missing values in data.
# Thi can indicate problems with data or data sources
#

using TimeSeries


"""
Load single sensor data from the file
"""
function loadchannel(path, station, channel)
    fname = "$path/sensors/station=$station/channel=$channel/$station-$channel.csv"
    dformat="YYYY-mm-dd HH:MM:SS"
    readtimearray(fname, format=dformat)
end


"""
Find time series resolution.
The resolution is a mode of differences between timestamps.
"""
function estimateresolution(ts :: TimeArray)
    # Lets calculate histogram for 10 bins. Then the resol
    function f(acc::Dict, v)
        if haskey(acc, v)
            acc[v] = acc[v] + 1
        else
            acc[v] = 1
        end
    end
    idx = timestamp(ts)
    diffs = idx[2:end] - idx[1:end-1]
    foldl(f, diffs; init=Dict())
end
