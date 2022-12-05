use color_eyre::eyre::Result;
use std::collections::HashSet;
use std::str::FromStr;

fn main() -> Result<()> {
    color_eyre::install()?;
    let input = include_str!("../inputs/main.0");

    let total: usize = input
        // Split input by lines
        .lines()
        .map(|line| {
            let asst_pair: Vec<HashSet<usize>> = line
                // Each pair is separated by a colon
                .split(",")
                .map(|assignment| {
                    let bounds: Vec<usize> = assignment
                        // In each pair the assignement range is separated by a dash
                        .split("-")
                        .map(|bound| {
                            usize::from_str(bound).expect("The bound is expected to be an int")
                        })
                        .collect();
                    let lower_bound = bounds[0];
                    let upper_bound = bounds[1];
                    HashSet::from_iter(lower_bound..=upper_bound)
                })
                .collect();
            let first_asst = &asst_pair[0];
            let second_asst = &asst_pair[1];
            first_asst.is_subset(&second_asst) || first_asst.is_superset(&second_asst)
        })
        .filter(|x| *x)
        .count();

    println!("{total}");

    Ok(())
}
