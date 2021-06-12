#! /usr/bin/python2


import sys
import copy


def recoverInput():
    """
        Function to recover inputs in the form of a list of sets
    """
    lPrograms = []
    for line in sys.stdin:
        lLine = line.split(' <-> ')
        lLine[1] = lLine[1].rstrip('\n')
        lLine[1] = lLine[1].split(', ')
        # Cast to a set of a list comprehension casting each string key of
        # program in the suited integer index
        setConnectedPrograms = set([int(sInteger) for sInteger in lLine[1]])
        lPrograms.insert(int(lLine[0]), setConnectedPrograms)
    return lPrograms


def extendSuccessors(lPrograms):
    """
        Function to compute the full successor set of each program
        Input : {list} lPrograms - list of sets built in recoverInput()
        @see recoverInput()
    """
    # For each program as index of the list
    for iIndex in range(len(lPrograms)):
        # Deep copy is needed to pass through elments of set
        setInitialSuccessors = copy.deepcopy(lPrograms[iIndex])
        for iSuccessor in setInitialSuccessors:
            # Current index is added to set of successors of the current
            # successor
            lPrograms[iSuccessor].add(iIndex)

            # A new set of successors is built
            setNewSuccessors = lPrograms[iIndex].union(lPrograms[iSuccessor])
            # Current program successor set is updated, as the one of the
            # current successor
            lPrograms[iIndex] = setNewSuccessors
            lPrograms[iSuccessor] = setNewSuccessors

    return lPrograms


def countGroups(lPrograms):
    """
        Function to count the number of different groups in the list of
        programs
        Each successors set is converted in frozenset so to be hashable.
        A set of set is produced. Only the unique versions of sets are kept
    """
    setOfSets = set(frozenset(elt) for elt in lPrograms)
    return len(setOfSets)


def main():
    lPrograms = recoverInput()
    lPrograms = extendSuccessors(lPrograms)
    print(len(lPrograms[0]))
    print(countGroups(lPrograms))
    return 0


if __name__ == '__main__':
    main()
