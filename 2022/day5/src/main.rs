use color_eyre::eyre::Report;
use std::str::FromStr;

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

#[derive(Debug)]
struct Stacks<'a> {
    stacks: Vec<Vec<&'a str>>,
}

impl<'a> Stacks<'a> {
    fn process_step(&mut self, step: Step) {
        for _n in 1..=step.how_much {
            let start_stack_id = step.start_stack_id - 1;
            let end_stack_id = step.end_stack_id - 1;
            let top = self.stacks[start_stack_id]
                .pop()
                .expect("step instructions should be reliable");
            self.stacks[end_stack_id].push(top);
        }
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

    let mut stacks: Stacks = Stacks{
        stacks: vec![vec![]; max_index]
    };
    for line in stack_lines {
        for stack_index in 0..max_index {
            let element_index = 1 + (stack_index * 4);
            let element = &line[element_index..element_index+1];
            if element != " " {
                stacks.stacks[stack_index].push(&element);
            }
        }
    }

    let steps: Vec<Result<Step, Report>> = instructions
        .lines()
        .map(|line| line.parse::<Step>())
        .collect();

    for step in steps {
        let step = step?;

        stacks.process_step(step);
    }
    stacks.display_top();

    Ok(())
}
