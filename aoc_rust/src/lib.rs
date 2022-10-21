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
            tokens
                .iter()
                .fold(0, |acc, x| if *x == '(' { acc + 1 } else { acc - 1 }) as isize
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

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn test_final_floor_1() {
                assert_eq!(0, final_floor("(())"));
            }

            #[test]
            fn test_final_floor_2() {
                assert_eq!(0, final_floor("()()"));
            }

            #[test]
            fn test_final_floor_3() {
                assert_eq!(3, final_floor("((("));
            }

            #[test]
            fn test_final_floor_4() {
                assert_eq!(3, final_floor("(()(()("));
            }

            #[test]
            fn test_final_floor_5() {
                assert_eq!(3, final_floor("))((((("));
            }

            #[test]
            fn test_final_floor_6() {
                assert_eq!(-1, final_floor("())"));
            }

            #[test]
            fn test_final_floor_7() {
                assert_eq!(-1, final_floor("))("));
            }

            #[test]
            fn test_final_floor_8() {
                assert_eq!(-3, final_floor(")))"));
            }

            #[test]
            fn test_final_floor_9() {
                assert_eq!(-3, final_floor(")())())"));
            }


            #[test]
            fn test_first_basement_floor_1() {
                assert_eq!(1, first_basement_floor(")"));
            }

            #[test]
            fn test_first_basement_floor_2() {
                assert_eq!(5, first_basement_floor("()()))"));
            }
        }
    }

    pub mod day_2 {
        struct PresentDimensions {
            length: usize,
            width: usize,
            height: usize,
        }

        pub fn part1(input: &str) -> String {
            let total: usize = input
                .lines()
                .map(|line| dimensions_to_paper_surface(line_to_dimensions(line)))
                .sum();
            format!("{total}")
        }
        pub fn part2(input: &str) -> String {
            let total: usize = input
                .lines()
                .map(|line| dimensions_to_ribbon_length(line_to_dimensions(line)))
                .sum();
            format!("{total}")
        }

        fn line_to_dimensions(input: &str) -> PresentDimensions {
            let dimensions_str: Vec<&str> = input.split('x').collect();
            PresentDimensions {
                length: dimensions_str[0].parse::<usize>().unwrap(),
                width: dimensions_str[1].parse::<usize>().unwrap(),
                height: dimensions_str[2].parse::<usize>().unwrap(),
            }
        }

        fn dimensions_to_paper_surface(dimensions: PresentDimensions) -> usize {
            let first = dimensions.length * dimensions.width;
            let second = dimensions.width * dimensions.height;
            let third = dimensions.height * dimensions.length;
            let smaller = first.min(second).min(third);
            2 * first + 2 * second + 2 * third + smaller
        }

        fn dimensions_to_ribbon_length(dimensions: PresentDimensions) -> usize {
            let first = 2 * (dimensions.length + dimensions.width);
            let second = 2 * (dimensions.width + dimensions.height);
            let third = 2 * (dimensions.height + dimensions.length);
            first.min(second).min(third) + dimensions.length * dimensions.width * dimensions.height
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn test_dimensions_to_paper_surface_1() {
                let dimensions = PresentDimensions {
                    length: 2,
                    width: 3,
                    height: 4,
                };
                assert_eq!(58, dimensions_to_paper_surface(dimensions));
            }

            #[test]
            fn test_dimensions_to_paper_surface_2() {
                let dimensions = PresentDimensions {
                    length: 1,
                    width: 1,
                    height: 10,
                };
                assert_eq!(43, dimensions_to_paper_surface(dimensions));
            }

            #[test]
            fn test_dimensions_to_ribbon_length_1() {
                let dimensions = PresentDimensions {
                    length: 2,
                    width: 3,
                    height: 4,
                };
                assert_eq!(34, dimensions_to_ribbon_length(dimensions));
            }
            #[test]
            fn test_dimensions_to_ribbon_length_2() {
                let dimensions = PresentDimensions {
                    length: 1,
                    width: 1,
                    height: 10,
                };
                assert_eq!(14, dimensions_to_ribbon_length(dimensions));
            }
        }
    }
}

use crate::year_2015::day_1;
use crate::year_2015::day_2;
pub fn solve_aoc(aoc: AoCInput) -> Result<String, String> {
    match aoc.year {
        2015 => match aoc.day {
            1 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = day_1::part1(&input);
                let part2_solution = day_1::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            2 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = day_2::part1(&input);
                let part2_solution = day_2::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            _ => Err(format!(
                "Day {} for year {} not implemented yet",
                aoc.day, aoc.year
            )),
        },
        _ => Err(format!("Year {} not implemented yet", aoc.year)),
    }
}

fn get_input_from_file(aoc: &AoCInput) -> String {
    let file_path = &aoc.input;
    println!("Opening file {file_path}");
    let contents = fs::read_to_string(file_path).expect("Unexpected error while reading the file");
    contents
}
