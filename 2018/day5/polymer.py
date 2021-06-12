import sys

def react(char_stream):
    new_char_stream = [char_stream[0]]
    prev_char = new_char_stream[0]
    for i in range(1, len(char_stream)):
        curr_char = char_stream[i]
        prev_char = new_char_stream[-1] if len(new_char_stream) != 0 else '+'
        if curr_char.lower() == prev_char.lower() and (
            (curr_char.isupper() and prev_char.islower())
            or (curr_char.islower() and prev_char.isupper())
        ):
            new_char_stream.pop()
        else:
            new_char_stream.append(curr_char)
    return new_char_stream

with open(sys.argv[1], 'r') as f:
    char_stream = list(f.read().rstrip('\n'))
print("original stream : ", ''.join(char_stream))
print(len(char_stream))



new_char_stream = react(char_stream)
print('new stream : ', ''.join(new_char_stream))
print(len(new_char_stream))

mini = len(new_char_stream)

for char in 'abcdefghijklmnopqrstuvwxyz':
    work_stream = new_char_stream

    work_stream = [value for value in work_stream if value not in [char, char.upper()]]

    new_work_stream = react(work_stream)

    size = len(new_work_stream)

    mini = size if size < mini else mini
    print('Removing {}/{} produces len {}'.format(char, char.upper(), len(new_work_stream)))

print('Definite min : {}'.format(mini))

