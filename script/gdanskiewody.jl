# Fetch data from Gdanskie Wody source
#
# # Gdanskie Wody
# System pomiarów meteorologicznych i hydrologicznych aglomeracji gdańskiej
# URL: https://pomiary.gdanskiewody.pl/account/dashboard
#

using ConfParser
using HTTP
using DataFrames
using JSON
using CSV
using Dates
using TimeSeries


# Path the the configuration file
const CONFIG_PATH = "production.config"
# Station channel types
const CHANNEL_NAMES = [:rain, :water, :winddir, :windlevel, :temp, :pressure, :humidity, :sun]


"Configuration object"
struct Config
    apikey::String
    outputfolder::String
end

"""
Load configuration data from external file
"""
function loadconfig()::Config
    conf = ConfParse(CONFIG_PATH, "ini")
    parse_conf!(conf)
    apikey = retrieve(conf, "default", "gdanskiewody-apikey")
    outputfolder = retrieve(conf, "default", "output-folder")
    Config(apikey, outputfolder)
end


""" Fetch station list as a DataFrame"""
function fetchstations(config::Config)
    headers = ["Authorization" => "Bearer $(config.apikey)"]
    r = HTTP.request("GET", "https://pomiary.gdanskiewody.pl/rest/stations", headers)
    response_data = JSON.parse(String(r.body))
    rows = response_data["data"]
    colnames = Tuple([Symbol(k) for k in keys(rows[1])])
    DataFrame([NamedTuple{colnames}(values(d)) for d in rows])
end


"""
Update data for all stations and channels.
Only update channels for active stations and available channels.
"""
function listchannels(stations) :: Array{NamedTuple{(:s, :c),Tuple{Int64, Symbol}}}
    channels = []
    active = stations[stations.active, :]
    for station in eachrow(active)
        sc = filter(c -> station[c], CHANNEL_NAMES)
        foreach(c -> push!(channels, (s=station.no, c=c)), sc)
    end
    channels
end


""" The API allows only to fetch single day and single channel
"""
function fetchchannelday(config, station, channel, day)
    dayformatted = Dates.format(day, "YYYY-mm-dd")
    url = "https://pomiary.gdanskiewody.pl/rest/measurements/$station/$channel/$dayformatted"
    headers = ["Authorization" => "Bearer $(config.apikey)"]
    response = HTTP.request("GET", url, headers)
    response_data = JSON.parse(String(response.body))
    if response_data["status"] == "error"
        println("Error reading $station-$channel")
        println(response_data["message"])
        []
    else
        filter(r -> r[2] != nothing, response_data["data"])
    end
end


""" Fetch channel data for the given period
"""
function fetchchannel(config, station, channel, startdate, enddate) :: Union{TimeArray, Nothing}
    days = startdate:Dates.Day(1):enddate
    daysdata = [fetchchannelday(config, station, channel, d) for d in days]
    data = collect(Iterators.flatten(daysdata))
    index = [Dates.DateTime(d[1], "Y-m-d HH:MM:SS") for d in data]
    values = map(d -> d[2], data)
    if isempty(values)
        nothing
    else
        TimeArray(index, values, [:value])
    end
end


"""
Update channel.
Since fetching data is expensive (and we don't know when the data starts)
We will first check the last timestamp in the saved channel and only fetch
data starting from this timestamp.
"""
function updatechannel(config, station, channel)
    println("$station - $channel")
    dformat="YYYY-mm-dd HH:MM:SS"
    fpath= "$(config.outputfolder)/sensors/station=$station/channel=$channel"
    # Ensure that the path exists
    mkpath(fpath)
    fname = "$fpath/$station-$channel.csv"
    enddate = Dates.today()
    if isfile(fname)
        ta = readtimearray(fname, format=dformat)
        lasttimestamp = last(timestamp(ta))
        startdate = Date(lasttimestamp)
        ta2 = fetchchannel(config, station, channel, startdate, enddate)
        if isnothing(ta)
            series = ta
        else
            series = vcat(ta, from(ta2, lasttimestamp + Dates.Minute(1)))
        end
    else
        startdate = Date(2005, 1, 1)
        series = fetchchannel(config, station, channel, startdate, enddate)
    end
    writetimearray(series, fname; format=dformat)
end


"""
Update local copy of data from the internet
"""
function updatedataset()
    config = loadconfig()
    stations = fetchstations(config)
    CSV.write("$(config.outputfolder)/stations.csv", stations)
    channels = listchannels(stations)
    foreach(sc -> updatechannel(config, sc.s, sc.c), channels)
end


"""
Main function for this module.
"""
#updatedataset()
