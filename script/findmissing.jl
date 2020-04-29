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
    idx = timestamp(ts)
    diffs = idx[2:end] - idx[1:end-1]
    bins :: Dict{Millisecond, Int64} = Dict()
    maxkey = Millisecond(0)
    maxvalue = 0
    for t in diffs
        counter = haskey(bins, t) ? bins[t] + 1 : 1
        if counter > maxvalue
            maxkey = t
        end
    end
    maxkey
end

"""
Find places with missing data points
"""
function findmissing(ts, resolution)
    missings = []
    prev = nothing
    for t in timestamp(ts)
        if prev != nothing  && t - prev > resolution
          push!(missings, prev)
        end
        prev = t
    end
    missings
end
