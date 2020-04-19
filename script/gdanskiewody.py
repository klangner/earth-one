# # Gdanskie Wody
# System pomiarów meteorologicznych i hydrologicznych aglomeracji gdańskiej
# URL: https://pomiary.gdanskiewody.pl/account/dashboard

import os
import requests
import pandas as pd
import datetime
from pathlib import Path
import configparser

DIR_NAME = os.path.dirname(__file__)

# Channel names
CHANNEL_NAMES = [
    'rain', 'water', 'winddir', 'windlevel',
    'temp', 'pressure', 'humidity', 'sun']


# Output dir
OUTPUT_DIR = Path(os.path.join(DIR_NAME, '../data/gdanskiewody'))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def read_config():
    """ Load configuration from external file """
    config = configparser.ConfigParser()
    config.read(os.path.join(DIR_NAME, '../secrets.ini'))
    return config



def fetch_stations(config):
    """ Fetch station list as pandas data frame"""
    headers = {'Authorization': 'Bearer {}'.format(config['api-keys']['gdanskie-wody'])}
    response = requests.get('https://pomiary.gdanskiewody.pl/rest/stations', headers=headers)
    response_data = response.json()
    return pd.DataFrame(response_data['data'])


def fetch_channel_day(config, station, channel, day):
    """ The API allows only to fetch single day and single channel
    """
    url = 'https://pomiary.gdanskiewody.pl/rest/measurements/{}/{}/{}'.format(
        station, channel, day.strftime('%Y-%m-%d'))
    headers = {'Authorization': 'Bearer {}'.format(config['api-keys']['gdanskie-wody'])}
    response = requests.get(url, headers=headers)
    response_data = response.json()
    if response_data['status'] == 'error':
        print(response_data['message'])
        return []
    return response_data['data']


def fetch_channel(config, station, channel, start_date, end_date):
    channel_data = []
    for n in range((end_date-start_date).days):
        day = start_date + datetime.timedelta(n)
        channel_data += fetch_channel_day(config, station, channel, day)
    df = pd.DataFrame(channel_data, columns=['time', channel])
    df = df.set_index('time')
    return df[channel]


def update_channel(config, station, channel):
    """Load last save channel data
       Fetch new information
       Save updated series
    """
    channel_file = OUTPUT_DIR / '{}-{}.csv'.format(station, channel)
    end_date = datetime.datetime.now().date()
    if Path(channel_file).is_file():
        df = pd.read_csv(channel_file, index_col=0, parse_dates=True)
        channel_data = df[channel]
        start_date = channel_data.index[-1].to_pydatetime().date()
        new_data = fetch_channel(config, station, channel, start_date, end_date)
        channel_data = channel_data.append(new_data)
    else:
        start_date = datetime.date(2005, 1, 1)
        channel_data = fetch_channel(config, station, channel, start_date, end_date)
    channel_data.dropna().to_csv(channel_file)


def update_station(config, station):
    if station['active']:
        print('Update station: {}'.format(station['no']))
        for channel in CHANNEL_NAMES:
            if station[channel]:
                print('  - channel: {}'.format(channel))
                update_channel(config, station['no'], channel)


def update_all_stations(config, stations):
    for _, station in stations.iterrows():
        update_station(config, station)


def main():
    config = read_config()
    # Always work with the fresh station list.
    stations = fetch_stations(config)
    stations.to_csv(OUTPUT_DIR / 'stations.csv', index=False)
    update_all_stations(config, stations)


if __name__ == "__main__":
    main()
