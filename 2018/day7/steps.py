import sys
import copy

def check_tasks(predecessors):
    for pr in predecessors:
        if pr != {'DONE'}: return True

def find_next(predecessors):
    for i in range(len(predecessors)):
        if predecessors[i] == set():
            return itoa(i)

def remove_done(predecessors, to_remove):
    for predecessor_list in predecessors:
        if to_remove in predecessor_list:
            predecessor_list.remove(to_remove)

    predecessors[atoi(to_remove)] = {'DONE'}

def atoi(char):
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return alphabet.index(char)

def itoa(index):
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return alphabet[index]

with open(sys.argv[1], mode='r') as f:
    arcs = []
    letters = set()

    # Building list of arcs and set of used letters.
    for line in f:
        line = line.split()
        predecessor = line[1]
        successor = line[7]
        # print('{} -> {}'.format(predecessor, successor))
        letters.add(predecessor)
        letters.add(successor)
        arcs.append((predecessor, successor))

# Building predecessors list
predecessors = [set() for _ in range(len(letters))]
for arc in arcs:
    predecessors[atoi(arc[1])].add(arc[0])

# Saving graph as predecessors lists.
predecessor_copy = copy.deepcopy(predecessors)

# For each existing step, finding the candidates, taking the first one.
# Then it is added to the ordered list of steps, and removed from
#  predecessors lists, and the step is flagged as done.
steps_done = [False] * len(letters)
order = []
while False in steps_done:
    candidates = [
        itoa(i) for i in range(len(predecessors))
            if len(predecessors[i]) == 0 and not steps_done[i]
    ]

    next_step = candidates[0]

    steps_done[atoi(next_step)] = True
    order.append(next_step)
    for predecessor_list in predecessors:
        if next_step in predecessor_list:
            predecessor_list.remove(next_step)

print(''.join(order))

# Initializing second part of puzzle
predecessors = predecessor_copy
workers_nb = 5
durations = [(60+i+1) for i in range(len(predecessors))]
workers_available = [True] * workers_nb
doing_list= [None] * workers_nb
seconds = 0
is_task_avail = True
while is_task_avail:

    # Assigning a ready task to all idle workers.
    next_task = find_next(predecessors)
    while True in workers_available and next_task is not None:

        # Finding first available worker and assigning next step.
        worker_id = workers_available.index(True)
        doing_list[worker_id] = [next_task, durations[atoi(next_task)]]
        predecessors[atoi(next_task)] = {'DOING'}
        workers_available[worker_id] = False

        next_task = find_next(predecessors)

    # Working = decrementing needed time to complete a task
    for worker_id in range(workers_nb):
        if doing_list[worker_id] is not None:
            # Decrementing tasks countdown.
            doing_list[worker_id][1] -= 1

            # Task is done. Worker going back to idle state.
            if doing_list[worker_id][1] == 0:
                workers_available[worker_id] = True
                task_done = doing_list[worker_id][0]
                doing_list[worker_id] = None

                # Removing task from predecessors.
                remove_done(predecessors, task_done)

    seconds += 1
    is_task_avail = check_tasks(predecessors)

print(seconds)
