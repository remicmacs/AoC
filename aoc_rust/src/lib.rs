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

    pub mod day_3 {
        use std::collections::HashSet;
        pub fn part1(input: &str) -> String {
            let house_nb = how_many_houses_get_presents(input);
            format!("{house_nb}")
        }

        pub fn part2(input: &str) -> String {
            let house_nb = how_many_houses_get_presents_with_robot(input);
            format!("{house_nb}")
        }

        #[derive(Clone, Copy, Hash, Eq, PartialEq, Debug)]
        struct Position {
            x: isize,
            y: isize,
        }

        fn go_north(init_pos: &Position) -> Position {
            Position {
                x: init_pos.x,
                y: init_pos.y + 1,
            }
        }

        fn go_south(init_pos: &Position) -> Position {
            Position {
                x: init_pos.x,
                y: init_pos.y - 1,
            }
        }

        fn go_east(init_pos: &Position) -> Position {
            Position {
                x: init_pos.x + 1,
                y: init_pos.y,
            }
        }

        fn go_west(init_pos: &Position) -> Position {
            Position {
                x: init_pos.x - 1,
                y: init_pos.y,
            }
        }

        fn how_many_houses_get_presents(directions: &str) -> usize {
            let init_pos = Position { x: 0, y: 0 };
            let mut positions = HashSet::from([init_pos]);
            let mut curr_pos = init_pos;
            for direction in directions.trim().chars() {
                curr_pos = get_new_pos(direction, &curr_pos);
                positions.insert(curr_pos);
            }
            positions.len()
        }

        fn get_new_pos(direction: char, curr_pos: &Position) -> Position {
            match direction {
                '^' => go_north(curr_pos),
                'v' => go_south(curr_pos),
                '>' => go_east(curr_pos),
                '<' => go_west(curr_pos),
                _ => panic!("should be unreachable"),
            }
        }

        fn how_many_houses_get_presents_with_robot(directions: &str) -> usize {
            let init_pos = Position { x: 0, y: 0 };
            let mut santa_positions = HashSet::from([init_pos]);
            let mut robot_positions = HashSet::from([init_pos]);
            let mut santa_curr_pos = init_pos;
            let mut robot_curr_pos = init_pos;
            for (i, direction) in directions.trim().chars().enumerate() {
                if i % 2 == 0 {
                    santa_curr_pos = get_new_pos(direction, &santa_curr_pos);
                    santa_positions.insert(santa_curr_pos);
                } else {
                    robot_curr_pos = get_new_pos(direction, &robot_curr_pos);
                    robot_positions.insert(robot_curr_pos);
                }
            }

            let all_pos: HashSet<_> = robot_positions.union(&santa_positions).collect();
            all_pos.len()
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn test_how_many_houses_get_presents_1() {
                assert_eq!(2, how_many_houses_get_presents(">"));
            }

            #[test]
            fn test_how_many_houses_get_presents_2() {
                assert_eq!(4, how_many_houses_get_presents("^>v<"));
            }

            #[test]
            fn test_how_many_houses_get_presents_3() {
                assert_eq!(2, how_many_houses_get_presents("^v^v^v^v^v"));
            }

            #[test]
            fn test_how_many_houses_get_presents_with_robot_1() {
                assert_eq!(3, how_many_houses_get_presents_with_robot("^v"));
            }

            #[test]
            fn test_how_many_houses_get_presents_with_robot_2() {
                assert_eq!(3, how_many_houses_get_presents_with_robot("^>v<"));
            }

            #[test]
            fn test_how_many_houses_get_presents_with_robot_3() {
                assert_eq!(11, how_many_houses_get_presents_with_robot("^v^v^v^v^v"));
            }
        }
    }

    pub mod day_4 {
        pub fn part1(input: &str) -> String {
            let res = find_md5_hash_with_x_leading_zeroes(5, input.trim());
            format!("{res}")
        }

        pub fn part2(input: &str) -> String {
            let res = find_md5_hash_with_x_leading_zeroes(6, input.trim());
            format!("{res}")
        }

        fn find_md5_hash_with_x_leading_zeroes(zeroes_nb: usize, input: &str) -> usize {
            use regex::Regex;
            let mut int_candidate = 0;
            let configurable_regex_str = format!("^0{{{}}}.*$", zeroes_nb);
            let re = Regex::new(&configurable_regex_str).unwrap();
            loop {
                let str_candidate = format!("{input}{int_candidate}");
                let digest = md5::compute(str_candidate);
                let hex_string = format!("{:x}", digest);
                if re.is_match(&hex_string) {
                    return int_candidate;
                }
                int_candidate += 1;
            }
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn test_find_md5_hash_with_x_leading_zeroes_1() {
                let res = find_md5_hash_with_x_leading_zeroes(5, "abcdef");
                assert_eq!(res, 609043);
            }

            #[test]
            fn test_find_md5_hash_with_x_leading_zeroes_2() {
                let res = find_md5_hash_with_x_leading_zeroes(5, "pqrstuv");
                assert_eq!(res, 1048970);
            }
        }
    }

    pub mod day_5 {
        pub fn part1(input: &str) -> String {
            let nice_str_nb = input.lines().filter(|line| is_nice(line)).count();
            format!("{nice_str_nb}")
        }

        pub fn part2(input: &str) -> String {
            let nice_str_nb = input.lines().filter(|line| is_nice_new(line)).count();
            format!("{nice_str_nb}")
        }

        fn is_nice(s: &str) -> bool {
            use lazy_static::lazy_static;
            use regex::Regex;
            lazy_static! {
                static ref RE_VOWELS: Regex =
                    Regex::new(r"^.*[aeiou].*[aeiou].*[aeiou].*$").unwrap();
                static ref RE_FORBIDDEN: Regex = Regex::new(r"^.*(ab|cd|pq|xy).*$").unwrap();
            }

            (!RE_FORBIDDEN.is_match(s)) && RE_VOWELS.is_match(s) && contains_double_char(s)
        }

        fn is_nice_new(s: &str) -> bool {
            contains_double_pair(s) && contains_repeating_letter_with_separator(s)
        }

        fn contains_double_char(s: &str) -> bool {
            let mut cur_ch = '\0';
            for ch in s.chars() {
                if ch == cur_ch {
                    return true;
                }
                cur_ch = ch;
            }
            false
        }

        fn contains_double_pair(s: &str) -> bool {
            use std::collections::HashMap;
            let bytes = s.as_bytes();
            let mut map: HashMap<String, usize> = HashMap::<String, usize>::new();
            let pairs = bytes.chunks_exact(2);
            for pair in pairs {
                *map.entry(std::str::from_utf8(pair).unwrap().to_string())
                    .or_default() += 1;
            }

            let off_by_one_bytes = &bytes[1..];
            let off_by_one_pairs = off_by_one_bytes.chunks_exact(2);
            for pair in off_by_one_pairs {
                *map.entry(std::str::from_utf8(pair).unwrap().to_string())
                    .or_default() += 1;
            }
            if !map.clone().into_values().any(|x| x > 1) {
                return false;
            }

            let filtered_map: HashMap<&String, &usize> =
                map.iter().filter(|(_k, v)| **v > 1).collect();

            // For each string in the double pairs that where found
            for pair_str in filtered_map.into_keys() {
                // test if overlaps by : finding all matches of the string and
                // see if indices overlaps
                let left_found = s.find(pair_str).unwrap();
                let right_found = s.rfind(pair_str).unwrap();
                if right_found - left_found > 1 {
                    return true;
                }
            }
            false
        }

        fn contains_repeating_letter_with_separator(s: &str) -> bool {
            let mut prev_char = '\0';
            let mut cur_ch = '\0';
            for ch in s.chars() {
                if ch == prev_char {
                    return true;
                }
                prev_char = cur_ch;
                cur_ch = ch;
            }
            false
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn test_is_nice_1() {
                assert!(is_nice("ugknbfddgicrmopn"));
            }

            #[test]
            fn test_is_nice_2() {
                assert!(is_nice("aaa"));
            }

            #[test]
            fn test_is_naughty_1() {
                assert!(!is_nice("jchzalrnumimnmhp"));
            }

            #[test]
            fn test_is_naughty_2() {
                assert!(!is_nice("haegwjzuvuyypxyu"));
            }

            #[test]
            fn test_is_naughty_3() {
                assert!(!is_nice("dvszwmarrgswjxmb"));
            }

            #[test]
            fn test_contains_double_char_1() {
                assert!(contains_double_char("ugknbfddgicrmopn"));
            }

            #[test]
            fn test_contains_double_char_2() {
                assert!(contains_double_char("aaa"));
            }

            #[test]
            fn test_contains_double_char_3() {
                assert!(!contains_double_char("jchzalrnumimnmhp"));
            }

            #[test]
            fn test_contains_double_char_4() {
                assert!(contains_double_char("haegwjzuvuyypxyu"));
            }

            #[test]
            fn test_contains_double_char_5() {
                assert!(contains_double_char("dvszwmarrgswjxmb"));
            }

            #[test]
            fn test_is_nice_new_1() {
                assert!(is_nice_new("qjhvhtzxzqqjkmpb"));
            }

            #[test]
            fn test_is_nice_new_2() {
                assert!(is_nice_new("xxyxx"));
            }

            #[test]
            fn test_is_naughty_new_1() {
                assert!(!is_nice_new("uurcxstgmygtbstg"));
            }

            #[test]
            fn test_is_naughty_new_2() {
                assert!(!is_nice_new("ieodomkazucvgmuy"));
            }

            #[test]
            fn test_contains_double_pair_1() {
                assert!(!contains_double_pair("ieodomkazucvgmuy"));
            }

            #[test]
            fn test_contains_double_pair_2() {
                assert!(contains_double_pair("xxyxx"));
            }

            #[test]
            fn test_contains_double_pair_3() {
                assert!(!contains_double_pair("bbb"));
            }

            #[test]
            fn test_contains_repeating_letter_with_separator_1() {
                assert!(contains_repeating_letter_with_separator("xxyxx"));
            }

            #[test]
            fn test_contains_repeating_letter_with_separator_2() {
                assert!(contains_repeating_letter_with_separator("aaa"));
            }

            #[test]
            fn test_contains_repeating_letter_with_separator_3() {
                assert!(contains_repeating_letter_with_separator("xyx"));
            }

            #[test]
            fn test_contains_repeating_letter_with_separator_4() {
                assert!(contains_repeating_letter_with_separator("abcdefeghi"));
            }
            #[test]
            fn test_contains_repeating_letter_with_separator_5() {
                assert!(!contains_repeating_letter_with_separator("xyz"));
            }
        }
    }

    pub mod day_6 {
        pub fn part1(input: &str) -> String {
            use regex::Regex;
            use std::str::FromStr;
            let toggle_re = Regex::new(r"^toggle").unwrap();
            let turn_on_re = Regex::new(r"^turn on").unwrap();
            let coordinates_re = Regex::new(r"\d{1,3},\d{1,3}").unwrap();
            let mut grid = vec![vec![false; 1000]; 1000];
            for line in input.lines() {
                let splitted: Vec<&str> = line.split(" through ").collect();
                let first_part = splitted[0];
                let coords_start_candidates = coordinates_re.captures(first_part).unwrap();
                let coords_start = &coords_start_candidates[0];
                let second_part = splitted[1];
                let coords_end_candidates = coordinates_re.captures(second_part).unwrap();
                let coords_end = &coords_end_candidates[0];

                let splitted_start: Vec<&str> = coords_start.split(",").collect();
                let splitted_end: Vec<&str> = coords_end.split(",").collect();

                let x_start = usize::from_str(&splitted_start[0]).unwrap();
                let y_start = usize::from_str(&splitted_start[1]).unwrap();
                let x_end = usize::from_str(&splitted_end[0]).unwrap();
                let y_end = usize::from_str(&splitted_end[1]).unwrap();

                if toggle_re.is_match(line) {
                    // Toggle
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            grid[i][j] = !grid[i][j];
                        }
                    }
                } else if turn_on_re.is_match(line) {
                    // Turn on
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            grid[i][j] = true;
                        }
                    }
                } else {
                    // Turn off
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            grid[i][j] = false;
                        }
                    }
                }
            }

            let flat: Vec<bool> = grid.into_iter().flatten().collect();
            let count = flat.iter().filter(|x| **x).count();
            format!("{count}")
        }

        pub fn part2(input: &str) -> String {
            use regex::Regex;
            use std::str::FromStr;
            let toggle_re = Regex::new(r"^toggle").unwrap();
            let turn_on_re = Regex::new(r"^turn on").unwrap();
            let coordinates_re = Regex::new(r"\d{1,3},\d{1,3}").unwrap();
            let mut grid = vec![vec![0; 1000]; 1000];
            for line in input.lines() {
                let splitted: Vec<&str> = line.split(" through ").collect();
                let first_part = splitted[0];
                let coords_start_candidates = coordinates_re.captures(first_part).unwrap();
                let coords_start = &coords_start_candidates[0];
                let second_part = splitted[1];
                let coords_end_candidates = coordinates_re.captures(second_part).unwrap();
                let coords_end = &coords_end_candidates[0];

                let splitted_start: Vec<&str> = coords_start.split(",").collect();
                let splitted_end: Vec<&str> = coords_end.split(",").collect();

                let x_start = usize::from_str(&splitted_start[0]).unwrap();
                let y_start = usize::from_str(&splitted_start[1]).unwrap();
                let x_end = usize::from_str(&splitted_end[0]).unwrap();
                let y_end = usize::from_str(&splitted_end[1]).unwrap();

                if toggle_re.is_match(line) {
                    // Toggle
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            grid[i][j] += 2;
                        }
                    }
                } else if turn_on_re.is_match(line) {
                    // Turn on
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            grid[i][j] += 1;
                        }
                    }
                } else {
                    // Turn off
                    for i in x_start..=x_end {
                        for j in y_start..=y_end {
                            if grid[i][j] > 0 {
                                grid[i][j] -= 1;
                            }
                        }
                    }
                }
            }

            let flat: Vec<usize> = grid.into_iter().flatten().collect();
            let sum: usize = flat.iter().sum();
            format!("{sum}")
        }
    }
}

mod year_2022 {
    pub mod day_1 {
        pub fn part1(input: &str) -> String {
            let most = input
                .split("\n\n")
                .map(|x| compute_elf_calories(x))
                .max()
                .unwrap();
            format!("{most}")
        }

        pub fn part2(input: &str) -> String {
            let mut elves = input
                .split("\n\n")
                .map(|x| compute_elf_calories(x))
                .collect::<Vec<usize>>();

            elves.sort_by_key(|&v| std::cmp::Reverse(v));
            let tot = elves.iter().take(3).sum::<usize>();
            format!("{tot}")
        }

        fn compute_elf_calories(input: &str) -> usize {
            input.lines().map(|x| x.parse::<usize>().unwrap_or(0))
                .sum()
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn compute_elf_calories_test_1() {
                assert_eq!(compute_elf_calories("1000\n2000\n3000"), 6000);
            }
            #[test]
            fn compute_elf_calories_test_2() {
                assert_eq!(compute_elf_calories("4000"), 4000);
            }
            #[test]
            fn compute_elf_calories_test_3() {
                assert_eq!(compute_elf_calories("5000\n6000"), 11000);
            }
            #[test]
            fn compute_elf_calories_test_4() {
                assert_eq!(compute_elf_calories("7000\n8000\n9000"), 24000);
            }
            #[test]
            fn compute_elf_calories_test_5() {
                assert_eq!(compute_elf_calories("10000"), 10000);
            }
        }
    }

    pub mod day_2 {

        pub fn part1(input: &str) -> String {
            let tot: usize = input
                .lines()
                .map(|line| calculate_round(line))
                .sum();
            format!("{tot}")
        }

        pub fn part2(input: &str) -> String {
            format!("Not implemented")
        }

        fn resolve_round(adversary: &str, me: &str) -> usize 
        {
            match (adversary, me) {
                ("A", "X") => 3,
                ("A", "Y") => 6,
                ("A", "Z") => 0,
                ("B", "X") => 0,
                ("B", "Y") => 3,
                ("B", "Z") => 6,
                ("C", "X") => 6,
                ("C", "Y") => 0,
                ("C", "Z") => 3,
                _ => 0,
            }
        }

        fn calculate_round(input: &str) -> usize {
            use itertools::Itertools;
            input
                .split_terminator(" ")
                .collect_tuple()
                .map(|(adversary, me)| {
                    let result = resolve_round(adversary, me);
                    match me {
                        "X" => result + 1,
                        "Y" => result + 2,
                        "Z" => result + 3,
                        _ => 0,
                    }
                }).unwrap_or(0)
        }

        #[cfg(test)]
        mod tests {
            use super::*;
            #[test]
            fn nothing() {
                panic!("at the disco");
            }
        }
    }
}

pub fn solve_aoc(aoc: AoCInput) -> Result<String, String> {
    match aoc.year {
        2015 => match aoc.day {
            1 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_1::part1(&input);
                let part2_solution = year_2015::day_1::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            2 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_2::part1(&input);
                let part2_solution = year_2015::day_2::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            3 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_3::part1(&input);
                let part2_solution = year_2015::day_3::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            4 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_4::part1(&input);
                let part2_solution = year_2015::day_4::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            5 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_5::part1(&input);
                let part2_solution = year_2015::day_5::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            6 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2015::day_6::part1(&input);
                let part2_solution = year_2015::day_6::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            }
            _ => Err(format!(
                "Day {} for year {} not implemented yet",
                aoc.day, aoc.year
            )),
        },
        2022 => match aoc.day {
            1 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2022::day_1::part1(&input);
                let part2_solution = year_2022::day_1::part2(&input);
                Ok(format!("{part1_solution}\n{part2_solution}"))
            },
            2 => {
                let input = get_input_from_file(&aoc);
                let part1_solution = year_2022::day_2::part1(&input);
                let part2_solution = year_2022::day_2::part2(&input);
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
