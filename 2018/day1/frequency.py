import sys

frequency = 0

history = []

history.append(frequency)

commands = []

with open(sys.argv[1], 'r') as f:
    for line in f :
        operator, value = line[0], int(line[1:])
        value = value if (operator is '+') else -value
        frequency = frequency + value
        if frequency in history:
            print(frequency)
            exit(0)
        history.append(frequency)
        commands.append(value)

    i = 0
    l = len(commands)

    while frequency not in history[:-1]:
        value = commands[(i % l)]
        frequency += value
        history.append(frequency)
        i += 1


print(frequency)