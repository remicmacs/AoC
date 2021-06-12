#! /usr/bin/python2


def calculateManhattan(iNumber):
    tVector = processVector(iNumber)
    print('Vector for {}th square'.format(str(iNumber)))
    print(tVector)
    return abs(tVector[0]) + abs(tVector[1])


def processVector(iNumber):
    # Moves right and up are odd, down and left are even
    print('Processing Manhattan distance for ' + str(iNumber))
    iNumber -= 1
    dListMoves = {'right': 0, 'up': 0, 'left': 0, 'down': 0}
    iDistance = 1
    lDirections = ['right', 'up', 'left', 'down']
    iSpiralIndex = 0

    while iNumber > 0:
        sCurrentDirection = lDirections[iSpiralIndex % len(lDirections)]
        # print('Current direction movement = ' + sCurrentDirection)
        # print('Current step size = ' + str(iDistance))
        iNumber -= iDistance
        dListMoves[sCurrentDirection] += iDistance

        if sCurrentDirection == 'up' or sCurrentDirection == 'down':
            iDistance += 1
        iSpiralIndex += 1
    dListMoves[sCurrentDirection] += iNumber
    print('Number of moves :')
    print(dListMoves)

    iTotalDistanceY = dListMoves['up'] - dListMoves['down']
    iTotalDistanceX = dListMoves['right'] - dListMoves['left']

    return (iTotalDistanceX, iTotalDistanceY)


def findNearest(iNumber):
    dGrid = {(0, 0): 1}
    iCurrentIndex = 2
    iCurrent = 1
    while iCurrent < iNumber:
        # Process current square
        tCurrentVector = processVector(iCurrentIndex)
        print('Current vector :')
        print(tCurrentVector)
        tUpLeft = (tCurrentVector[0]-1, tCurrentVector[1]+1)
        tUp = (tCurrentVector[0], tCurrentVector[1]+1)
        tUpRight = (tCurrentVector[0]+1, tCurrentVector[1]+1)
        tRight = (tCurrentVector[0]+1, tCurrentVector[1])
        tDownRight = (tCurrentVector[0]+1, tCurrentVector[1]-1)
        tDown = (tCurrentVector[0], tCurrentVector[1]-1)
        tDownLeft = (tCurrentVector[0]-1, tCurrentVector[1]-1)
        tLeft = (tCurrentVector[0]-1, tCurrentVector[1])

        print('Tuples :')
        print(tUpLeft, tUp, tUpRight, tRight, tDownRight, tDown, tDownLeft, tLeft)
        iUpLeft = recoverValue(tUpLeft, dGrid)
        iUp = recoverValue(tUp, dGrid)
        iUpRight = recoverValue(tUpRight, dGrid)
        iRight = recoverValue(tRight, dGrid)
        iDownRight = recoverValue(tDownRight, dGrid)
        iDown = recoverValue(tDown, dGrid)
        iDownLeft = recoverValue(tDownLeft, dGrid)
        iLeft = recoverValue(tLeft, dGrid)
        print('Values : ')
        print(iUpLeft, iUp, iUpRight, iRight, iDownRight, iDown, iDownLeft, iLeft)
        dGrid[tCurrentVector] = iUpLeft + iUp + iUpRight + iRight + iDownRight + iDown + iDownLeft + iLeft
        print('Current Grid :')
        print(dGrid)
        iCurrentIndex += 1
        iCurrent = dGrid[tCurrentVector]

    print('Index reached :')
    print(iCurrentIndex)
    print('Value of index :')
    print(iCurrent)
    return 0


def recoverValue(tKey, dGrid):
    if tKey in dGrid:
        return dGrid[tKey]
    return 0


def main():
    iNumber = input()
    iDistance = calculateManhattan(iNumber)
    print('Manhattan distance : ')
    print(iDistance)
    findNearest(iNumber)
    return 0


if __name__ == '__main__':
    main()
