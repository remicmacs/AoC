#! /usr/bin/python2


import sys


def recoverList():
    lInstructions = []

    for line in sys.stdin:
        iInteger = int(line)
        lInstructions.append(iInteger)

    return lInstructions


def runInstructions(lInstructions):
    iCurrentIndex = 0
    iSteps = 0
    iLen = len(lInstructions)

    while iCurrentIndex >= 0 and iCurrentIndex < iLen:
        iOffset = lInstructions[iCurrentIndex]
        if iOffset >= 3:
            lInstructions[iCurrentIndex] -= 1
        else:
            lInstructions[iCurrentIndex] += 1
        iCurrentIndex += iOffset
        iSteps += 1
    return iSteps


def main():
    lInstructions = recoverList()
    print(lInstructions)
    print(runInstructions(lInstructions))
    return 0


if __name__ == '__main__':
    main()
