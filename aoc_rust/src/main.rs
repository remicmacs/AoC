use std::env;
use std::fs;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path: String;
    match args.len() {
        // expected number of args
        4 => {
            let year: u32 = match args[1].parse::<u32>() {
                Ok(number) => {
                    if number < 2022 && number > 2014 {
                        println!("Valid year {number}");
                        number
                    }
                    else {
                        println!("Please chose a year in [2015-2021] range");
                        process::exit(1);
                    }
                },
                _ => {
                        println!("Expected a number year !");
                        process::exit(1);
                }
            };

            let day_nb: u32 = match args[2].parse::<u32>() {
                Ok(number) => {
                    if number < 26 && number > 0 {
                        println!("Valid day_nb {number}");
                        number
                    }
                    else {
                        println!("Please chose a day in [1-25] range");
                        process::exit(1);
                    }
                },
                _ => {
                        println!("Expected a number day !");
                        process::exit(1);
                }
            };

            let input_file = &args[3];

            file_path = format!("../{year}/day{day_nb}/inputs/{input_file}");
        },
        _ => {
            println!("This program expects 3 positional args <year>, <day_nb> and <input_file>");
            // Generic error code
            process::exit(1);
        },
    }

    println!("Opening file {file_path}");
    let contents = fs::read_to_string(file_path).expect("Unexpected error while reading the file");

    let tokens: Vec<char> = contents.chars().collect();

    let mut first_reach_basement = 0;
    let mut floor = 0;
    for (i, token) in tokens.iter().enumerate() {
        match token {
            '(' => floor += 1,
            ')' => floor -= 1,
            _ => continue,
        }
        if first_reach_basement == 0 && floor < 0 {
            first_reach_basement = i + 1;
        }
    }

    println!("{floor}\n{first_reach_basement}");
}
