use serde::{Deserialize, Serialize};
use ini::Ini;
use reqwest;
use reqwest::header;
use csv;


/// Program configuration read from the external file
#[derive(Debug)]
struct Config {
    api_key: String,
    output_folder: String
}

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

#[derive(Deserialize, Debug)]
struct StationsResponse {
    status: String,
    message: String,
    data: Vec<StationInfo>
}

impl Config {
    fn load(file_path: &str) -> Config {
        let conf = Ini::load_from_file(file_path).unwrap();
        let section = conf.section(Some("Gdanskie Wody")).unwrap();
        let api_key = section.get("apikey").unwrap();
        let output_folder = section.get("output-folder").unwrap();
        Config {api_key: api_key.to_owned(), output_folder: output_folder.to_owned()}
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

/// Main
fn main() {
    let config = Config::load("production.config");
    let stations = fetch_stations(&config).unwrap();
    save_stations(&stations, &config).unwrap();
    // List channels
    // Update channels

    println!("{:?}", config);
}
