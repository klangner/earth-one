using Interact, Plots
using CSV


const CHANNEL_NAMES = ["water", "rain", "winddir", "windlevel", "temp", "pressure", "humidity", "sun"]
stations = CSV.read("data/gdanskiewody/stations.csv"; truestrings=["True"], falsestrings=["False"])


@manipulate for channel in CHANNEL_NAMES, station in stations[stations.water, :no]
    df = CSV.read("data/gdanskiewody/$station-$channel.csv"; dateformat="yyyy-mm-dd HH:MM:SS")
    scatter(df[!, :time], df[!, :water], title="Station $station", marker=:auto)
end
