#! /usr/bin/python2


import sys
import copy


def caculateMaxReallocation(lMemoryBanks):
    """
        Main logic function
        Input = initial memory banks state represented by a list of integers
        Output = tuple of (Number of needed reallocation cycles, size of the
        loop between the two recurring states)
    """
    # History initialization
    lHistory = []

    lCurrentMemoryBanks = lMemoryBanks
    iNbOfReallocations = 0

    while lCurrentMemoryBanks not in lHistory:
        # Debug print statements
        # print('History:')
        # print(lHistory)

        # At each turn current memory banks state is saved before reallocation
        lHistory.append(lCurrentMemoryBanks)

        lCurrentMemoryBanks = reallocate(lCurrentMemoryBanks)

        # Debug print statements
        # print('Reallocated memory banks :')
        # print(lCurrentMemoryBanks)
        iNbOfReallocations += 1

    # Size of reallocation loop is number of reallocation - position of
    # previous occurence of the returning state
    iIndex = lHistory.index(lCurrentMemoryBanks)
    iLoop = len(lHistory) - iIndex
    return iNbOfReallocations, iLoop


def reallocate(lCurrentMemoryBanks):
    """
        Function to reallocate the memory banks according to the instructions
        given
    """
    # A deep copy is needed so as to create a new list object
    lReallocated = copy.deepcopy(lCurrentMemoryBanks)

    # The lowest index of the fullest memory banks is found
    iIndex = findMaxIndex(lReallocated)
    # The number of blocks to redistribute
    iRemainingBlocks = lReallocated[iIndex]
    lReallocated[iIndex] = 0

    iLen = len(lReallocated)

    # Loop to redistribute every block
    # Optimization is possible based on the number of blocks to redistribute
    # divided by the number of blocks but brute force just works for now
    while iRemainingBlocks > 0:
        # Modulo operator used to loop through list indexes
        iIndex = (iIndex + 1) % iLen
        lReallocated[iIndex] += 1
        iRemainingBlocks -= 1
    return lReallocated


def recoverInput():
    """
        Helper function to recover puzzle input
    """
    lMemoryBanks = []
    for line in sys.stdin:
        line = line.split('\t')
        line = [int(element) for element in line]
        lMemoryBanks = line
    return lMemoryBanks


def findMaxIndex(lMemoryBanks):
    """
        Helper function to find the index of the first fullest memory bank
    """
    iMaxValue = max(lMemoryBanks)
    iMaxIndex = lMemoryBanks.index(iMaxValue)
    return iMaxIndex


def main():
    lMemoryBanks = recoverInput()
    print(lMemoryBanks)
    findMaxIndex(lMemoryBanks)
    print(caculateMaxReallocation(lMemoryBanks))
    return 0


if __name__ == '__main__':
    main()
