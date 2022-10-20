use std::fs;

pub struct AoCInput {
    pub year: u32,
    pub day: u32,
    pub input: String,
}

mod year_2015 {
    pub mod day_1 {
        pub fn part1(input: &str) -> String {
            let final_floor = final_floor(&input);
            format!("{final_floor}")
        }

        pub fn part2(input: &str) -> String {
            let first_basement_floor = first_basement_floor(&input);
            format!("{first_basement_floor}")
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
    }

}

use crate::year_2015::day_1;
pub fn solve_aoc(aoc: AoCInput) -> Result<String, String> {
    match aoc.year {
        2015 => {
            match aoc.day {
                1 => {
                    let input = get_input_from_file(&aoc);
                    let part1_solution = day_1::part1(&input);
                    let part2_solution = day_1::part2(&input);
                    Ok(format!("{part1_solution}\n{part2_solution}"))
                },
                _ => { Err(format!("Day {} for year {} not implemented yet", aoc.day, aoc.year)) },
            }
        },
        _ => { Err(format!("Year {} not implemented yet", aoc.year)) },
    }
}

fn get_input_from_file(aoc: &AoCInput) -> String {
    let file_path = &aoc.input;
    println!("Opening file {file_path}");
    let contents = fs::read_to_string(file_path).expect("Unexpected error while reading the file");
    contents
}

