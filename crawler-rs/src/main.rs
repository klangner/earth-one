use serde::{Deserialize, Serialize};
use serde_json::value::Value;
use chrono::{NaiveDate, NaiveDateTime};
use ini::Ini;
use reqwest;
use reqwest::header;
use csv;
use timeseries::TimeSeries;


/// List of channels
static CHANNEL_NAMES: [&'static str; 8] = 
    ["rain", "water", "winddir", "windlevel", "temp", "pressure", "humidity", "sun"];

/// Program configuration read from the external file
#[derive(Debug)]
struct Config {
    api_key: String,
    output_folder: String
}

/// station data based on API
#[derive(Deserialize, Serialize, Debug)]
struct StationInfo {
    no: u32,
    name: String,
    active: bool,
    rain: bool,
    water: bool,
    winddir: bool,
    windlevel: bool,
    temp: bool,
    pressure: bool,
    humidity: bool,
    sun: bool
}

/// Response to the query about stations
#[derive(Deserialize, Debug)]
struct StationsResponse {
    status: String,
    message: String,
    data: Vec<StationInfo>
}

// Sensor data based on API
#[derive(Deserialize, Serialize, Debug)]
struct SensorResponse {
    status: String,
    message: String,
    data: Vec<(String, Value)>
}

/// Single sensor description.
#[derive(Debug)]
struct Sensor {
    station: u32,
    channel: String
}


impl Config {
    /// Configuration is stored in external file
    fn load(file_path: &str) -> Config {
        let conf = Ini::load_from_file(file_path).unwrap();
        let section = conf.section(Some("Gdanskie Wody")).unwrap();
        let api_key = section.get("apikey").unwrap();
        let output_folder = section.get("output-folder").unwrap();
        Config {api_key: api_key.to_owned(), output_folder: output_folder.to_owned()}
    }
}

impl StationInfo {
    /// Check if given channel is active
    fn has_channel(&self, name: &str) -> bool {
        match name {
            "rain" => self.rain,
            "water" => self.water,
            "winddir" => self.winddir,
            "windlevel" => self.windlevel,
            "temp" => self.temp,
            "pressure" => self.pressure,
            "humidity" => self.humidity,
            "sun" => self.sun,
            _ => false
        }
    }
}

/// Fetch list of station from the API
fn fetch_stations(config: &Config) -> Result<Vec<StationInfo>,reqwest::Error> {
    let client = reqwest::blocking::Client::new();
    let response = client
                    .get("https://pomiary.gdanskiewody.pl/rest/stations")
                    .header(header::AUTHORIZATION, format!("Bearer {}", config.api_key))
                    .send()?;
    let decoded_response = response.json::<StationsResponse>()?;
    Ok(decoded_response.data)
}

/// Save station to the CSV file
fn save_stations(stations: &Vec<StationInfo>, config: &Config) -> Result<(), csv::Error>{
    let fname = format!("{}/stations.csv", config.output_folder);
    let mut wtr = csv::Writer::from_path(fname)?;
    stations.iter().for_each(|s| wtr.serialize(&s).unwrap());
    wtr.flush()?;
    Ok(())
}


/// Calculate list of activate sensors
fn list_sensors(stations: &Vec<StationInfo>) -> Vec<Sensor> {
    stations.iter()
        .filter(|station| station.active)
        .flat_map(|station| 
            CHANNEL_NAMES.iter()
                .filter(|name| station.has_channel(name))
                .map(|name| Sensor{station: station.no, channel: name.to_string()} )
                .collect::<Vec<Sensor>>())
        .collect()
}


/// The API allows only to fetch single day and single channel
fn fetch_sensor_day(config: &Config, sensor: &Sensor, day: &NaiveDate) -> Result<TimeSeries, reqwest::Error> {
    let day_formatted = day.to_string();
    let url = format!("https://pomiary.gdanskiewody.pl/rest/measurements/{}/{}/{}",
                        sensor.station, sensor.channel, day_formatted);
    let client = reqwest::blocking::Client::new();
    let response = client
                    .get(&url)
                    .header(header::AUTHORIZATION, format!("Bearer {}", config.api_key))
                    .send()?;
    let decoded_response = response.json::<SensorResponse>()?;
    let data = decoded_response.data
        .iter()
        .map(|(d, v)| (NaiveDateTime::parse_from_str(d, "%Y-%m-%d %H:%M:%S"), v.as_f64()))
        .filter(|(d, v)| d.is_ok() && v.is_some())
        .map(|(d, v)| (d.unwrap().timestamp(), v.unwrap()))
        .collect();
    Ok(TimeSeries::from_records(data))
}


/// Main
fn main() {
    let config = Config::load("production.config");
    let stations = fetch_stations(&config).unwrap();
    save_stations(&stations, &config).unwrap();
    let sensors = list_sensors(&stations);
    // Update sensors
    let now = NaiveDate::from_ymd(2020, 5, 4);
    let ts = fetch_sensor_day(&config, &sensors[0], &now).unwrap();
    ts.iter().for_each(|r| println!("{:?}", r));
}
