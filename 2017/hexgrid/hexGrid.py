#! /usr/bin/python2


import sys


def recoverMoves():
    line = sys.stdin.readline().rstrip('\n')
    lMoves = line.split(',')
    return lMoves


def processMoves(lMoves):
    dMoves = {}
    for sMove in lMoves:
        if sMove not in dMoves.keys():
            dMoves[sMove] = 1
        else:
            dMoves[sMove] += 1
    return dMoves


def moveNE(iNumberOfMoves, iColumn, iRow):
    """
        When moving NE, column count is increased, and row count decreased
            (row count negative upwards)
    """
    return (iColumn + iNumberOfMoves), (iRow - iNumberOfMoves)


def moveN(iNumberOfMoves, iColumn, iRow):
    """
        When moving N, column count doesn't change, row count decreases
    """
    return iColumn, (iRow - iNumberOfMoves)


def moveNW(iNumberOfMoves, iColumn, iRow):
    """
        When moving NW, column count decreases and row count doesn't change
    """
    return (iColumn - iNumberOfMoves), iRow


def moveSW(iNumberOfMoves, iColumn, iRow):
    return (iColumn - iNumberOfMoves), (iColumn + iNumberOfMoves)


def moveS(iNumberOfMoves, iColumn, iRow):
    return iColumn, (iRow + iNumberOfMoves)


def moveSE(iNumberOfMoves, iColumn, iRow):
    return (iColumn + iNumberOfMoves), iRow


def processCoordinates(dMoves):
    iRow = 0
    iColumn = 0

    dIncrements = {
        'ne': moveNE,
        'n': moveN,
        'nw': moveNW,
        'sw': moveSW,
        's': moveS,
        'se': moveSE
    }

    for key, value in dMoves.iteritems():
        iColumn, iRow = dIncrements[key](value, iColumn, iRow)

    return (iColumn, iRow)


def calculateHexDistance(tOrigin, tEnd):
    iOriginColumn, iOriginRow = tOrigin
    iEndColumn, iEndRow = tEnd
    return max(abs(iOriginColumn - iEndColumn),
               abs(iOriginColumn + iOriginRow - iEndColumn - iEndRow),
               abs(iOriginRow - iEndRow))


def main():
    lMoves = recoverMoves()
    dMoves = processMoves(lMoves)
    tCoordinates = processCoordinates(dMoves)
    print(tCoordinates)
    print(calculateHexDistance((0, 0), tCoordinates))
    """
    lTestCoordinates = [
        (1, 1),
        (2, 1),
        (1, 2),
        (2, -1),
        (3, -1),
        (3, -2),
        (1, -3),
        (2, -3),
        (1, -2),
        (-1, -1),
        (-1, -1),
        (-2, -1),
        (-2, 1),
        (-3, 1),
        (-3, 2),
        (-2, 3),
        (-1, 2),
        (-1, 3),
        (2, 3),
        (-3, -2)]
    for tCoordinates in lTestCoordinates:
        print('For case ' + str(tCoordinates) + ' you have to make ' +
              str(calculateHexDistance((0, 0), tCoordinates)) + ' steps')
    """
    iMaxDistance = 0
    for iIndex in range(len(lMoves)):
        dCurrentMoves = processMoves(lMoves[:iIndex+1])
        tCurrentCoordinates = processCoordinates(dCurrentMoves)
        iDistance = calculateHexDistance((0, 0), tCurrentCoordinates)
        iMaxDistance = max(iDistance, iMaxDistance)
    print('Max distance has been ' + str(iMaxDistance) + ' steps')
    return 0


if __name__ == '__main__':
    main()
