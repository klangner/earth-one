use ini::Ini;


#[derive(Debug)]
struct Config {
    api_key: String,
    output_folder: String
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

fn fetch_stations(config: &Config) -> Vec<String> {
    vec![]
}

fn main() {
    let config = Config::load("production.config");
    let stations = fetch_stations(&config);

    println!("{:?}", config);
    println!("{:?}", stations);
}
