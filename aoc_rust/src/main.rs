use std::env;
use std::process;

use aoc_rust::*;

fn parse_cmdline_args() -> Result<AoCInput, &'static str> {
    let args: Vec<String> = env::args().collect();
    let file_path: String;
    let year: u32;
    let day_nb: u32;
    match args.len() {
        // expected number of args
        4 => {
            year = match args[1].parse::<u32>() {
                Ok(number) => {
                    if number < 2023 && number > 2014 {
                        number
                    } else {
                        return Err("Please chose a year in [2015-2022] range");
                    }
                }
                _ => return Err("Expected a number year !"),
            };

            day_nb = match args[2].parse::<u32>() {
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

    Ok(AoCInput {
        year: year,
        day: day_nb,
        input: file_path,
    })
}

fn main() {
    let input: AoCInput = match parse_cmdline_args() {
        Ok(valid_struct) => valid_struct,
        Err(err_msg) => {
            println!("{err_msg}");
            process::exit(1);
        }
    };

    match solve_aoc(input) {
        Ok(solution) => println!("{solution}"),
        Err(err_msg) => {
            println!("{err_msg}");
            process::exit(1);
        }
    };
}
