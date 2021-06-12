#! /usr/bin/python2


import sys


def recoverInput():
    """
        Helper function to recover input as ascii codes
    """
    sLine = sys.stdin.readline().rstrip('\n')
    lLengths = [ord(cElt) for cElt in sLine]
    lLengths = lLengths + [17, 31, 73, 47, 23]
    return lLengths


def reverseNumbers(lNumbers, iIndex, iLength):
    """
        Helper function to reverse sublist for iLength elements from iIndex
    """
    # Find whether max index is inside list or loops to the beginning
    iIndexMax = iIndex + iLength
    iLen = len(lNumbers)

    # Sublist is inside list
    if iIndexMax < iLen:
        lSublist = lNumbers[iIndex:iIndexMax]
        lSublist = lSublist[::-1]
        lNumbers = lNumbers[:iIndex] + lSublist + lNumbers[iIndexMax:]
    # Sublist loops to the beginning of list
    else:
        iIndexMax = iIndexMax % iLen
        lBeginning = lNumbers[iIndex:iLen]
        lEnd = lNumbers[0:iIndexMax]
        iSeparation = len(lBeginning)
        lSublist = lBeginning + lEnd
        lSublist = lSublist[::-1]

        # Resplitting reversed sublist
        lBeginning = lSublist[:iSeparation]
        lEnd = lSublist[iSeparation:]

        lNumbers = lEnd + lNumbers[iIndexMax:iIndex] + lBeginning
    return lNumbers


def processTurn(iSkipSize, iLenght, lNumbers, iIndex):
    """
        Function to make one turn of the hash
    """
    lNumbers = reverseNumbers(lNumbers, iIndex, iLenght)
    return lNumbers, iIndex


def hashLengths(lLengths, lNumbers, iIndex=0, iSkipSize=0):
    """
        Function to process length sequence for each turn
        Inputs:
            lLengths = lengths sequences
            lNumbers = sequence of numbers
            iIndex = current index
            iSkipSize = current skipping offset
    """
    for iLenght in lLengths:
        lNumbers, iIndex = processTurn(iSkipSize, iLenght,  lNumbers, iIndex)
        iIndex = (iIndex + iLenght + iSkipSize) % len(lNumbers)
        iSkipSize += 1
    return lNumbers, iIndex, iSkipSize


def getSparseHash(lLengths):
    """
        Function to make 64 rounds of hashing length sequence
    """
    iIndex = 0
    iSkipSize = 0
    lNumbers = range(256)
    for iRounds in range(64):
        lNumbers, iIndex, iSkipSize = hashLengths(
            lLengths, lNumbers, iIndex, iSkipSize)
    return lNumbers


def splitSparseHash(lNumbers):
    """
        Function to split final numbers sequence in 16 groups of 16 numbers
    """
    lDenseHashes = []
    iPreviousIndex = 0
    iIndex = 16
    while iPreviousIndex < len(lNumbers):
        lDenseHashes.append(lNumbers[iPreviousIndex:iIndex])
        iPreviousIndex = iIndex
        iIndex += 16

    return lDenseHashes


def xorDenseHashes(lDenseHashes):
    """
        Function to return dense hash after
        XOR each digit of each 16 digits group of the sparse hash
    """
    lXoredDenseHashes = []

    for lDenseHash in lDenseHashes:
        lXoredHash = lDenseHash[0] ^ lDenseHash[1]
        iIndex = 2
        while iIndex < 16:
            lXoredHash = lXoredHash ^ lDenseHash[iIndex]
            iIndex += 1
        lXoredDenseHashes.append(lXoredHash)

    return lXoredDenseHashes


def convertToHex(lXoredDenseHashes):
    """
        Function to convert hash to hex string
    """
    sHexHash = ''
    for iXoredHash in lXoredDenseHashes:
        sHexHash += '{:02x}'.format(iXoredHash)
    return sHexHash


def main():
    lLengths = recoverInput()
    # print(lLengths)
    # lHashedNumbers, iIndex, iSkipSize = hashLengths(lLengths, iRange)
    # print(lHashedNumbers)
    lSparseHash = getSparseHash(lLengths)
    print(lSparseHash)
    lDenseHashes = splitSparseHash(lSparseHash)
    print(lDenseHashes)
    print(str(len(lDenseHashes)))
    lXoredDenseHashes = xorDenseHashes(lDenseHashes)
    print(lXoredDenseHashes)
    print(convertToHex(lXoredDenseHashes))
    return 0


if __name__ == '__main__':
    main()
