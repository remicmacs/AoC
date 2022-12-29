use std::collections::{HashSet, VecDeque};

fn find_start_of_message_marker(s: &str) -> usize {
    let mut ring: VecDeque<char> = VecDeque::with_capacity(14);

    for (i, c) in s.chars().enumerate() {
        // just fill the buffer for now
        if i < 14 {
            ring.push_back(c);
            continue;
        }

        // check if no duplicates in current buffer
        let mut charset: HashSet<char> = HashSet::new();
        for ch in ring.iter() {
            charset.insert(*ch);
        }
        let ok = charset.len() == 14;
        // if no duplicates in buffer, return
        if ok {
            return i;
        }
        ring.pop_front();
        ring.push_back(c)
    }

    return 0;
}

fn find_start_of_packet_marker(s: &str) -> usize {
    let mut first: char;
    let mut second: char;
    let mut third: char;
    let mut fourth: char;
    let mut marker_pos = 4;

    let mut chars = s.chars();

    // fill up the first 4 chars registers
    first = chars.next().unwrap();
    second = chars.next().unwrap();
    third = chars.next().unwrap();
    fourth = chars.next().unwrap();

    for (i, c) in s.chars().enumerate() {
        if i < 4 {
            continue;
        }

        // here check if it's the marker
        if first != second &&
            first != third &&
            first != fourth &&
            second != third &&
            second != fourth &&
            third != fourth {
            marker_pos = i;
            break;
        }

        // rotate
        first = second;
        second = third;
        third = fourth;
        fourth = c;

        continue;
    }

    return marker_pos;
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
