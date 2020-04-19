# # Gdanskie Wody
# System pomiarów meteorologicznych i hydrologicznych aglomeracji gdańskiej
# URL: https://pomiary.gdanskiewody.pl/account/dashboard

using ConfParser
using HTTP
using DataFrames
using JSON
using CSV


# Path the the configuration file
const CONFIG_PATH = "secrets.ini"
# Path to the data folder
const OUTPUT_FOLDER = "data/gdanskiewody"
# Gdanskie wody API URL
const API_URL = "https://pomiary.gdanskiewody.pl/rest/stations"
# Station channel types
const CHANNEL_NAMES = [:rain, :water, :winddir, :windlevel, :temp, :pressure, :humidity, :sun]

"Configuration object"
struct Config
    apikey::String
end

"""
Load configuration data from external file
"""
function loadconfig()::Config
    conf = ConfParse(CONFIG_PATH)
    parse_conf!(conf)
    apikey = retrieve(conf, "api-keys", "gdanskie-wody")
    Config(apikey)
end

"""
Initialize data folder is not exists
"""
function initoutput()
    mkpath(OUTPUT_FOLDER)
end


""" Fetch station list as a DataFrame"""
function fetchstations(config::Config)
    headers = ["Authorization" => "Bearer $(config.apikey)"]
    r = HTTP.request("GET", API_URL, headers)
    response_data = JSON.parse(String(r.body))
    rows = response_data["data"]
    colnames = Tuple([Symbol(k) for k in keys(rows[1])])
    DataFrame([NamedTuple{colnames}(values(d)) for d in rows])
end


"""
Update channel. Fetch only new data from the last point saved.
"""
function updatechannel(station, channel)
    fname = "$OUTPUT_FOLDER/$station-$channel.csv"
    df = CSV.read(fname)
    print(last(df))
end


"""
Update data for all stations
"""
function updatestations(stations)
    for station in eachrow(stations)
        if station.active
            for channel in CHANNEL_NAMES
                if station[channel]
                    updatechannel(station.no, channel)
                end
            end
        end
    end
end


"""
Update local copy of data from the internet
"""
function updatedata()
    config = loadconfig()
    initoutput()
    stations = fetchstations(config)
    CSV.write("$OUTPUT_FOLDER/stations.csv", stations)
    updatestations(stations)
end


updatedata()



#
# def fetch_channel_day(station, channel, day):
#     """ The API allows only to fetch single day and single channel
#     """
#     url = 'https://pomiary.gdanskiewody.pl/rest/measurements/{}/{}/{}'.format(
#         station, channel, day.strftime('%Y-%m-%d'))
#     response = requests.get(url, headers=HTTP_HEADERS)
#     response_data = response.json()
#     if response_data['status'] == 'error':
#         print(response_data['message'])
#         return []
#     return response_data['data']
#
#
# def fetch_channel(station, channel, start_date, end_date):
#     channel_data = []
#     for n in range((end_date-start_date).days):
#         day = start_date + datetime.timedelta(n)
#         channel_data += fetch_channel_day(station, channel, day)
#     df = pd.DataFrame(channel_data, columns=['time', channel])
#     df = df.set_index('time')
#     return df[channel]
#
#
# def update_channel(station, channel):
#     """Load last save channel data
#        Fetch new information
#        Save updated series
#     """
#     channel_file = OUTPUT_DIR / '{}-{}.csv'.format(station, channel)
#     end_date = datetime.datetime.now().date()
#     if Path(channel_file).is_file():
#         df = pd.read_csv(channel_file, index_col=0, parse_dates=True)
#         channel_data = df[channel]
#         start_date = channel_data.index[-1].to_pydatetime().date()
#         new_data = fetch_channel(station, channel, start_date, end_date)
#         channel_data = channel_data.append(new_data)
#     else:
#         start_date = datetime.date(2005, 1, 1)
#         channel_data = fetch_channel(station, channel, start_date, end_date)
#     channel_data.dropna().to_csv(channel_file)
