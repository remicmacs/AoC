#! /usr/bin/python2


import sys
import knot_hash


def recoverInput():
    """
        Helper function to get input
    """
    sInput = sys.stdin.readline().rstrip('\n')
    return sInput


def getFinalHash(sInput):
    """
        Function to process a knot hash with the day 10 challenge as library
    """
    lLengths = knot_hash.converToAsciiInput(sInput)
    lSparseHash = knot_hash.getSparseHash(lLengths)
    lDenseHash = knot_hash.splitSparseHash(lSparseHash)
    lXoredDenseHashes = knot_hash.xorDenseHashes(lDenseHash)
    sHexHash = knot_hash.convertToHex(lXoredDenseHashes)
    return sHexHash


def processLines(sInput):
    """
        Function to return a binary map (array of 128 strings of 128 binary
        chars) of the disk space
    """
    lLines = [(sInput + '-' + str(iIndex)) for iIndex in range(128)]
    lFinal = []

    for sLine in lLines:
        # Get hex knot hash
        sFinalHash = getFinalHash(sLine)
        # Split string in 2 hex digits numbers
        lHexNumbers = splitHexLine(sFinalHash)
        # Convert to binary value (string)
        sBinary = convertToBinaryValue(lHexNumbers)
        lFinal.append(sBinary)
    return lFinal


def convertToBinaryValue(lHexNumbers):
    """
        Function to convert a list of 2 hex digits string
        to 8 binary digit string
    """
    sBinary = ''
    for sHexNumber in lHexNumbers:
        sBinary += '{0:08b}'.format(int(sHexNumber, 16))
    return sBinary


def splitHexLine(sHexLine):
    """
        Function to split hex string in list of 2 hex digits strings
    """
    lHexNumbers = [sHexLine[iIndex:iIndex+2]
                   for iIndex in range(0, len(sHexLine), 2)]
    return lHexNumbers


def countUsedSquares(lBinaryLines):
    """
        Function to count number of used squares
    """
    iUsed = 0
    for sBinaryLine in lBinaryLines:
        iUsed += sBinaryLine.count('1')
    return iUsed


def makeRegionBreadthFirst(tCell, lBinaryMap, setTuples, lRegions=[]):
    """
        Breadth-first algorithm to build used regions from a used cell
        Inputs:
            tCell: departure cell
            lBinaryMap: map of used and unused cells
            setTuples: candidates cells set
            lRegions: regions already existing
        Outputs:
            lRegions: with a new region
            setTuples: removed of visited cells
    """
    # If cell is not used, return
    if not isUsed(tCell, lBinaryMap):
        return lRegions, setTuples

    # New region initialization
    setRegion = set()

    # Visiting candidates queue initialising
    queueFrontier = []
    queueFrontier.insert(0, tCell)

    # Visited list initialising
    dVisited = {}
    dVisited[tCell] = True

    # Current region is composed at least of starting cell
    setRegion.add(tCell)

    # Algorithm has to deplete queue of candidates cells
    while queueFrontier != []:
        tCurrent = queueFrontier.pop()
        for tNext in findNeighbors(tCurrent, lBinaryMap):
            # Visited cell is removed from candidates
            if tNext in setTuples:
                setTuples.remove(tNext)

            # When cell is used and not already visited, added to queue and
            # region
            if isUsed(tNext, lBinaryMap) and tNext not in dVisited:
                queueFrontier.insert(0, tNext)
                dVisited[tNext] = True
                setRegion.add(tNext)

    # List of region is updated
    lRegions.append(setRegion)
    return lRegions, setTuples


def findNeighbors(tCell, lBinaryMap):
    """
        Function to return a list of tuples that are potential neighbors
        to the current cell
    """
    iXCoord = tCell[0]
    iYCoord = tCell[1]
    lNeighbors = []
    if iYCoord != 0:
        tCellUp = (iXCoord, iYCoord - 1)
        lNeighbors.append(tCellUp)
    if iXCoord != 0:
        tCellLeft = (iXCoord - 1, iYCoord)
        lNeighbors.append(tCellLeft)
    if iYCoord != 127:
        tCellDown = (iXCoord, iYCoord + 1)
        lNeighbors.append(tCellDown)
    if iXCoord != 127:
        tCellRight = (iXCoord + 1, iYCoord)
        lNeighbors.append(tCellRight)
    return lNeighbors


def isUsed(tCell, lBinaryMap):
    return lBinaryMap[tCell[0]][tCell[1]] == '1'


def findRegions(lBinaryMap):
    """
        Function that return the number of regions of used squares
    """
    lRegions = []
    lNumbersX = range(128)
    lNumbersY = range(128)
    setTuples = set([(x, y) for x in lNumbersX for y in lNumbersY])

    while len(setTuples) != 0:
        tCell = setTuples.pop()
        lRegions, setTuples = makeRegionBreadthFirst(
            tCell, lBinaryMap, setTuples, lRegions)

    return len(lRegions)


def main():
    sInput=recoverInput()
    lLines=processLines(sInput)
    print(countUsedSquares(lLines))
    print(findRegions(lLines))
    return 0


if __name__ == '__main__':
    main()
