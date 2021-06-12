import sys

events = []

with open(sys.argv[1], 'r') as f:
    for line in f:
        line = line.rstrip('\n')
        splitted_line = line.split()
        timestamp = ' '.join(splitted_line[:2]).lstrip('[').rstrip(']')
        translation_table = dict.fromkeys(map(ord, '- :'), None)
        timestamp = int(timestamp.translate(translation_table))
        action = ' '.join(splitted_line[2:])

        if action == 'wakes up':
            action = {'type': 'waking'}
        elif action == 'falls asleep':
            action = {'type': 'sleeping'}
        else:
            action = {'type': 'shifting', 'guard_id' : action.split()[1].lstrip('#')}

        tup = (timestamp, action)

        events.append(tup)

# Sorting in chronological order (from smallest timestamp to biggest)
events = sorted(events, key=lambda x: x[0])

sleep_time = -1
current_guard_id = -1
guards = {}
for event in events:
    timestamp, action = event
    # Build a hashmap of guards and their shift data.
    if action['type'] == 'shifting':
        current_guard_id = action['guard_id']
    elif action['type'] == 'sleeping':
        sleep_time = timestamp
    elif action['type'] == 'waking':
        start = sleep_time % 100
        stop = timestamp % 100

        # Shift data is an array of 60 values incremented every time the
        #   minute has been slept by the guard.
        if current_guard_id not in guards:
            guards[current_guard_id] = [0] * 60
        for i in range(start, stop):
            guards[current_guard_id][i] += 1

# Flatten the hashmap in a list for sorting purposes.
guards_ary = [(k,v) for k,v in guards.items()]
guards_ary = sorted(guards_ary, key=lambda x: sum(x[1]), reverse=True)

print(int(guards_ary[0][0])*guards_ary[0][1].index(max(guards_ary[0][1])))

guards_ary = sorted(guards_ary, key=lambda x: max(x[1]), reverse=True)

print(int(guards_ary[0][0])*guards_ary[0][1].index(max(guards_ary[0][1])))
