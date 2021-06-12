#! /usr/bin/python2


import sys


def recoverSanitizedStream():
    """
        Function to recover all valid stream
        Output : sStream without '!' and groups between '<>'
    """
    line = sys.stdin.readline()
    line = line.rstrip('\n')

    # Debug print statements
    # print('Uncleaned stream :')
    # print(line)

    # An empty string is created
    sLineCopy = ''
    # While the line is not depleted of all chars
    while len(line) > 0:
        # Taking a char and removing it from string
        char = line[0]
        line = line[1:]

        # Skipping two chars without copying if char is '!'
        if char == '!' and len(line) > 0:
            line = line[1:]
        else:
            sLineCopy += char

    # New empty string to collect non-garbage stream
    sLineCopy2 = ''
    # Var to count garbage as we go
    iGarbage = 0

    while len(sLineCopy) > 0:
        char = sLineCopy[0]
        sLineCopy = sLineCopy[1:]

        # When a garbage group is found
        if char == '<':
            # The opening caret will be counted so 1 is removed from total
            iGarbage -= 1
            while char != '>' and len(sLineCopy) > 0:
                char = sLineCopy[0]
                sLineCopy = sLineCopy[1:]
                iGarbage += 1
        else:
            sLineCopy2 += char

    # Print statement for part 2
    print('Number of garbage found : ' + str(iGarbage))
    return sLineCopy2


def sumObjects(sStream):
    """
        Function to process the summed value of all groups in cleaned stream
        Input : {string} sStream - Cleaned stream
        Output : {int} iSum - summed values of all groups
    """
    iIndex = 0
    iSum = 0

    # A stack is suited to follow the nesting levels
    stackBrackets = []

    while iIndex < len(sStream):
        char = sStream[iIndex]

        # A group opens
        if char == '{':
            stackBrackets.append(iIndex)
        # A group closes, and the value of the closed group is of its nesting
        # depth
        elif char == '}':
            iDepth = len(stackBrackets)
            iSum += iDepth
            stackBrackets.pop()

        iIndex += 1

    return iSum


def main():
    sStream = recoverSanitizedStream()
    print(sumObjects(sStream))
    return 0


if __name__ == '__main__':
    main()
