
fn find_marker(s: &str) -> usize {
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
    assert_eq!(7, find_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb"));
    assert_eq!(5, find_marker("bvwbjplbgvbhsrlpgdmjqwftvncz"));
    assert_eq!(6, find_marker("nppdvjthqldpwncqszvftbrmjlhg"));
    assert_eq!(10, find_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"));
    assert_eq!(11, find_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"));
    println!("{}", find_marker(input));
}
