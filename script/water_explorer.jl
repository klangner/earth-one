using Interact, Plots
using CSV
using Dates


const CHANNEL_NAMES = ["water", "rain", "winddir", "windlevel", "temp", "pressure", "humidity", "sun"]
stations = CSV.read("data/gdanskiewody/stations.csv"; truestrings=["True"], falsestrings=["False"])


@manipulate for station in stations[stations.water, :no],
                startday in Date(2018, 1, 1),
                endday in Date(Dates.now())
    channel = "water"
    df = CSV.read("data/gdanskiewody/$station-$channel.csv"; dateformat="yyyy-mm-dd HH:MM:SS")
    df2 = df[(df.time .> startday) .& (df.time .<= endday), :]
    ymax = length(df2.water) > 0 ? 1.2*maximum(df2.water) : 10
    scatter(df2.time, df2.water, title="Station $station",
            marker=([:dot], 2, 2, Plots.stroke(0)), ylims=(0, ymax))
end
