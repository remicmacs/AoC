use color_eyre::eyre::Report;
use std::{fmt, str::FromStr, thread, time};

#[derive(Debug)]
struct Step {
    how_much: usize,
    start_stack_id: usize,
    end_stack_id: usize,
}

impl FromStr for Step {
    type Err = color_eyre::Report;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        use lazy_static::lazy_static;
        use regex::Regex;
        lazy_static! {
            // Step string format : "move 1 from 8 to 7"
            static ref STEP_REGEX: Regex = Regex::new(
                r"move (\d+) from (\d) to (\d)"
            ).expect("This regexp is valid");
        }

        let groups = STEP_REGEX
            .captures_iter(s)
            .next()
            .expect("Regex must match a step");
        // Discarding the first group which matchs the whole regexp
        let relevant_groups = (groups.get(1), groups.get(2), groups.get(3));
        match relevant_groups {
            (Some(how_much_group), Some(start_stack_id_group), Some(end_stack_id_group)) => {
                let how_much: usize = how_much_group.as_str().parse()?;
                let start_stack_id: usize = start_stack_id_group.as_str().parse()?;
                let end_stack_id: usize = end_stack_id_group.as_str().parse()?;
                Ok(Step {
                    how_much,
                    start_stack_id,
                    end_stack_id,
                })
            }
            _ => Err(color_eyre::eyre::eyre!("not a valid step: {s:?}")),
        }
    }
}

#[derive(Debug, Clone)]
struct Stacks<'a> {
    stacks: Vec<Vec<&'a str>>,
}

impl<'a> Stacks<'a> {
    fn process_step_9000(&mut self, step: &Step) {
        let start_stack_id = step.start_stack_id - 1;
        let end_stack_id = step.end_stack_id - 1;
        for _n in 1..=step.how_much {
            let top = self.stacks[start_stack_id]
                .pop()
                .expect("step instructions should be reliable");
            self.stacks[end_stack_id].push(top);
        }
    }

    fn process_step_9001(&mut self, step: &Step) {
        let start_stack_id = step.start_stack_id - 1;
        let end_stack_id = step.end_stack_id - 1;
        let stack_len = self.stacks[start_stack_id].len();
        let final_len = stack_len - step.how_much;
        let tail = self.stacks[start_stack_id].split_off(final_len);
        self.stacks[end_stack_id].extend(tail);
    }

    fn display_top(&self) {
        let mut result = format!("");
        for stack in &self.stacks {
            let current = stack.last().unwrap();
            result = format!("{result}{current}");
        }
        println!("{result}");
    }
}

impl fmt::Display for Stacks<'_> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        // Find max size in all stacks
        let max_size = self.stacks.iter().map(|s| s.len()).max().unwrap();

        let mut all_stacks_str = format!("");
        // for max_size line
        // from the top
        for line_count in (1..=max_size).rev() {
            let mut current_line = format!("");
            // for each stack in order
            for stack in self.stacks.iter() {
                // format " [X] " (or "    " if no element) and append to current string
                if let Some(element) = stack.get(line_count - 1) {
                    current_line = format!("{current_line} [{element}] ");
                } else {
                    current_line = format!("{current_line}     ");
                }
            }
            all_stacks_str = format!("{all_stacks_str}{current_line}\n");
        }

        // Append "  %d  " for number of stack
        let mut indices_str = format!("");
        for i in 1..=self.stacks.len() {
            indices_str = format!("{indices_str}  {i}  ");
        }
        let stacks_str = format!("{all_stacks_str}{indices_str}");
        write!(f, "{}", stacks_str)
    }
}

fn main() -> color_eyre::Result<()> {
    color_eyre::install().unwrap();

    let input = include_str!("../inputs/main.0");
    let splitted: Vec<&str> = input.split("\n\n").collect();

    let stacks = splitted.get(0).expect("Stacks definition should exist");
    let instructions = splitted.get(1).expect("List of instructions should exist");

    // [D]                     [N] [F]
    // [H] [F]             [L] [J] [H]
    // [R] [H]             [F] [V] [G] [H]
    // [Z] [Q]         [Z] [W] [L] [J] [B]
    // [S] [W] [H]     [B] [H] [D] [C] [M]
    // [P] [R] [S] [G] [J] [J] [W] [Z] [V]
    // [W] [B] [V] [F] [G] [T] [T] [T] [P]
    // [Q] [V] [C] [H] [P] [Q] [Z] [D] [W]
    //  1   2   3   4   5   6   7   8   9
    //
    let mut stacks: Vec<&str> = stacks.lines().collect();
    let indices = stacks.pop().expect("Stack def must have indices");
    let indices: Vec<&str> = indices.trim().split("   ").collect();
    let max_index: usize = indices
        .into_iter()
        .map(|s| {
            s.parse::<usize>()
                .expect("all indices should be usize parsable")
        })
        .max()
        .expect("max of usize should not be debatable");

    let stack_lines: Vec<&str> = stacks.into_iter().rev().collect();

    let mut stacks: Stacks = Stacks {
        stacks: vec![vec![]; max_index],
    };
    for line in stack_lines {
        for stack_index in 0..max_index {
            let element_index = 1 + (stack_index * 4);
            let element = &line[element_index..element_index + 1];
            if element != " " {
                stacks.stacks[stack_index].push(&element);
            }
        }
    }

    let init_stacks = stacks.clone();

    let steps: Vec<Step> = instructions
        .lines()
        .map(|line| line.parse::<Step>().expect("I'm expecting a step here"))
        .collect();

    // TODO: display and sleep only if argument is passed
    // println!("{}\n\n", stacks);
    for step in &steps[..] {
        let step = step;

        stacks.process_step_9000(step);
        // println!("{step:#?}\n{stacks}\n\n");

        // let duration = time::Duration::from_millis(100);

        // thread::sleep(duration);
    }
    stacks.display_top();

    let mut stacks = init_stacks;
    // println!("{stacks}\n\n");
    for step in &steps[..] {
        let step = step;

        stacks.process_step_9001(step);
        // println!("{step:#?}\n{stacks}\n\n");

        // let duration = time::Duration::from_millis(100);

        // thread::sleep(duration);
    }
    stacks.display_top();

    Ok(())
}
