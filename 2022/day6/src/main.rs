use std::collections::{HashSet, VecDeque};

fn find_marker_of_nth_distinct_char(s: &str, n: usize) -> usize {
    let mut ring: VecDeque<char> = VecDeque::with_capacity(14);

    for (i, c) in s.chars().enumerate() {
        // just fill the buffer for now
        if i < n {
            ring.push_back(c);
            continue;
        }

        // check if no duplicates in current buffer
        let charset: HashSet<&char> = HashSet::from_iter(ring.iter());
        // if no duplicates in buffer, return
        if charset.len() == n {
            return i;
        }
        ring.pop_front();
        ring.push_back(c)
    }

    return 0;
}

fn find_start_of_message_marker(s: &str) -> usize {
    find_marker_of_nth_distinct_char(s, 14)
}

fn find_start_of_packet_marker(s: &str) -> usize {
    find_marker_of_nth_distinct_char(s, 4)
}

fn main() {
    let input = include_str!("../inputs/main.0");
    assert_eq!(7, find_start_of_packet_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb"));
    assert_eq!(5, find_start_of_packet_marker("bvwbjplbgvbhsrlpgdmjqwftvncz"));
    assert_eq!(6, find_start_of_packet_marker("nppdvjthqldpwncqszvftbrmjlhg"));
    assert_eq!(10, find_start_of_packet_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"));
    assert_eq!(11, find_start_of_packet_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"));
    println!("{}", find_start_of_packet_marker(input));

    assert_eq!(19, find_start_of_message_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb"));
    assert_eq!(23, find_start_of_message_marker("bvwbjplbgvbhsrlpgdmjqwftvncz"));
    assert_eq!(23, find_start_of_message_marker("nppdvjthqldpwncqszvftbrmjlhg"));
    assert_eq!(29, find_start_of_message_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"));
    assert_eq!(26, find_start_of_message_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"));
    println!("{}", find_start_of_message_marker(input));
}
