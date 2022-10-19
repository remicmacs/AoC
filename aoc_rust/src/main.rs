use std::env;
use std::fs;
use std::process;

fn parse_cmdline_args() -> Result<String, &'static str> {
    let args: Vec<String> = env::args().collect();
    let file_path: String;
    match args.len() {
        // expected number of args
        4 => {
            let year: u32 = match args[1].parse::<u32>() {
                Ok(number) => {
                    if number < 2022 && number > 2014 {
                        number
                    } else {
                        return Err("Please chose a year in [2015-2021] range");
                    }
                }
                _ => return Err("Expected a number year !"),
            };

            let day_nb: u32 = match args[2].parse::<u32>() {
                Ok(number) => {
                    if number < 26 && number > 0 {
                        number
                    } else {
                        return Err("Please chose a day in [1-25] range");
                    }
                }
                _ => return Err("Expected a number day !"),
            };

            let input_file = &args[3];

            file_path = format!("../{year}/day{day_nb}/inputs/{input_file}");
        }
        _ => {
            return Err("This program expects 3 positional args <year>, <day_nb> and <input_file>")
        }
    }

    Ok(file_path)
}

fn final_floor(input: &str) -> isize {
    let tokens: Vec<char> = input.chars().collect();
    tokens.iter().fold(0, |acc, x| if *x == '(' { acc + 1 } else { acc - 1 }) as isize
}

fn first_basement_floor(input: &str) -> usize {
    let tokens: Vec<char> = input.chars().collect();

    let mut first_basement_floor: usize = 0;
    let mut floor = 0;
    for (i, token) in tokens.iter().enumerate() {
        match token {
            '(' => floor += 1,
            ')' => floor -= 1,
            _ => continue,
        }
        if first_basement_floor == 0 && floor < 0 {
            first_basement_floor = i + 1;
        }
    }

    first_basement_floor
}

fn main() {
    let file_path: String;
    match parse_cmdline_args() {
        Ok(valid_str) => file_path = valid_str,
        Err(err_msg) => {
            println!("{err_msg}");
            process::exit(1);
        }
    };

    println!("Opening file {file_path}");
    let contents = fs::read_to_string(file_path).expect("Unexpected error while reading the file");

    let final_floor = final_floor(&contents);
    let first_basement_floor = first_basement_floor(&contents);
    println!("{final_floor}\n{first_basement_floor}");
}
