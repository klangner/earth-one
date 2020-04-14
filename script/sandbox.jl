using Interact
using DataFrames
using CSV
using StatsPlots
using Dates

# List of available channel types
const CHANNEL_NAMES = ["water", "rain", "winddir", "windlevel", "temp", "pressure", "humidity", "sun"]
# Load station as global DataFrame
stations = CSV.read("data/gdanskiewody/stations.csv"; truestrings=["True"], falsestrings=["False"])

# Filter stations by channel name and return as Dict
function stations_by_channel(channel_name::String) :: Dict{String, Integer}
    if channel_name == "water"
        stations[stations.water, [:name, :no]]
        Dict("Water A" => 552, "Water B" => 553)
    else
        Dict("Meteo A" => 552, "Meteo B" => 553)
    end
end

function dashboard()
    # Observables
    stationsobs = Observable(stations_by_channel(CHANNEL_NAMES[1]))
    # Widgets
    channels_widget = dropdown(CHANNEL_NAMES)
    stations_widget = dropdown(stationsobs)

    # Commands
    # update station list
    function update_stations(channel_name)
        stationsobs[] = stations_by_channel(channel_name)
    end
    # Connect commands
    on(update_stations, channels_widget)

    # Layout
    hbox(
        vbox(
            channels_widget,
            stations_widget))
end

display(dashboard())
