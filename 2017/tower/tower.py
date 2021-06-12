#! /usr/bin/python2


import sys
import copy


def findPredecessor(dTower, sKey):
    for key, value in dTower.iteritems():
        lSuccessors = value[1]
        if lSuccessors is not None and sKey in lSuccessors:
            return key


def sanitizeLine(sLine):
    """
        Helper function to sanitize inputs
        Input : one single line (string)
        Output : tuple of ([programname, weight], [list of successors or None])
    """
    # First program of line has successors
    if '->' in sLine:
        lSanitized = sLine.split('->')
        sHead = lSanitized[0]
        # List of successors is generated
        sSuccessors = lSanitized[1].lstrip().rstrip()
        lSuccessors = sSuccessors.split(', ')
    # Programs has no successors
    else:
        sHead = sLine
        lSuccessors = None

    # Head information is processed
    sHead = sHead.lstrip().rstrip()
    lHead = sHead.split(' ')
    lHead[1] = int(lHead[1].strip('()'))

    # Tuple is returned : ([programname, weight], [list of successors or None])
    return lHead, lSuccessors


def hasSuccessors(dTower, key):
    """
        Helper function to know if input program has successors or know
    """
    return not dTower[key][1] is None


def createTowerDict():
    """
        Input recovering function
        Output : dictionary
        {programname : (weight, [list of successor programs] || None) }
    """
    # List comprehension to recover each line sanitized
    # Inside a dictionnary comprehension to separate program name as key
    # and weight and successors as value
    dTowerdict = {element[0][0]: (element[0][1], element[1])
                  for element in [sanitizeLine(line) for line in sys.stdin]}
    return dTowerdict


def isSuccessor(dTower, key):
    """
        Helper function to know if program is a successor or not
    """
    dTowerCopy = copy.deepcopy(dTower)

    # Filter dict to keep only programs with successors
    dTowerCopy = {
        key: value for key, value in dTowerCopy.iteritems()
        if value[1] is not None}

    # print('Key researched is [{}]'.format(key))

    # If program name is found in successors, return True
    for value in dTowerCopy.values():
        if key in value[1]:
            return True

    return False


def findBase(dTower):
    """
        Function to find base of program tower
    """
    for key in dTower.keys():
        if hasSuccessors(dTower, key) and not isSuccessor(dTower, key):
            return key


def balanceDisc(dTower, sBase):
    lSuccessors = dTower[sBase][1]
    # print(lSuccessors)
    if lSuccessors is None:
        return
    # print('Supporting program : ' + sBase)
    # print('Successors : ' + str(lSuccessors))

    dSuccessorsStack = {}
    for sSuccessor in lSuccessors:
        dSuccessorsStack[sSuccessor] = processStack(sSuccessor, dTower)

    # print(dSuccessorsStack)
    sKey = findUnbalancedSuccessor(dSuccessorsStack)
    print('balanceDisc: unbalanced successor found :')
    print(sKey)
    if sKey is not None:
        return balanceDisc(dTower, sKey)
    return calculateDifference(dTower, sBase)


def calculateDifference(dTower, sKey):
    print('calculateDifference: beginning')
    print(sKey)
    sBaseOfUnbalancedDisc = findPredecessor(dTower, sKey)
    print(sBaseOfUnbalancedDisc)

    dStack = processStack(sBaseOfUnbalancedDisc, dTower)
    print(dStack)
    dWeights = dStack['dSuccessorsWeight']
    iUnbaW = dWeights[sKey]
    for key in dWeights.keys():
        if key is not sKey:
            iBalanced = dWeights[key]

    iDiff = iBalanced - iUnbaW
    print('difference = ' + str(iDiff))
    iIdeal = dTower[sKey][0] + iDiff
    return (sKey, iDiff, iIdeal)


def findUnbalancedSuccessor(dSuccessorsStack):
    lProgWeight = []

    for sKey in dSuccessorsStack.keys():
        iTotalWeight = dSuccessorsStack[sKey]['iTotalWeight']
        lProgWeight.append((sKey, iTotalWeight))

    lProgWeight.sort(key=lambda key: key[1])

    if lProgWeight[0][1] < lProgWeight[1][1]:
        return lProgWeight[0][0]
    elif lProgWeight[-1][1] > lProgWeight[-2][1]:
        return lProgWeight[-1][0]
    else:
        return None


def processStack(sSuccessor, dTower):
    """
        Function that returns a dictionary of useful information on weight of
        stack
        Inputs : sSuccessor = key of the base of the studied stack
                 dTower : tree of programs
        Outputs : dictionary of form {iBaseWeight: (weight of base program),
                 iTotalWeight: (total weight of stack),
                 dSuccessorsWeight: (dictionnary of successors and their total weights}
    """
    dStack = {}
    iSummedWeights = 0
    iBaseWeight = dTower[sSuccessor][0]
    sNames = sSuccessor + ' + ('
    sStack = str(iBaseWeight) + ' + ('
    iSummedWeights += iBaseWeight
    dStack['iBaseWeight'] = iBaseWeight

    lStacked = dTower[sSuccessor][1]
    dSuccessorsWeight = {}

    if lStacked is not None:
        for sStacked in lStacked:
            sNames += sStacked + ' + '
            iStackedWeight = totalWeightOfProgram(sStacked, dTower)
            sStack += str(iStackedWeight) + ' + '
            dSuccessorsWeight[sStacked] = iStackedWeight
            iSummedWeights += iStackedWeight
    dStack['dSuccessorsWeight'] = dSuccessorsWeight

    sStack = sNames.rstrip(' + ') + ') = ' + sStack.rstrip(' + ') + ')' + ' = ' + str(iSummedWeights)
    # print(sStack)
    dStack['iTotalWeight'] = iSummedWeights
    return dStack


def totalWeightOfProgram(sKey, dTower):
    """
        Helper function to find the total weight of a program and the ones it
        supports
    """
    iSum = dTower[sKey][0]

    lSuccessors = dTower[sKey][1]
    if lSuccessors is not None:
        for sSuccessor in dTower[sKey][1]:
            iSum += totalWeightOfProgram(sSuccessor, dTower)
    return iSum


def main():
    dTower = createTowerDict()
    sBase = findBase(dTower)
    print(balanceDisc(dTower, sBase))
    return 0


if __name__ == '__main__':
    main()
