#! /usr/bin/python2


import sys


def recoverInstructions():
    """
        Helper function to recover instructions
    """
    lInstructions = []
    for line in sys.stdin:
        # Remove new line mark
        line = line.rstrip('\n')

        # Split line between instruction and condition
        line = line.split(' if ')
        dInstruction = {'instruction': line[0], 'condition': line[1]}

        # Formatting of inputs
        sIntruction = dInstruction['instruction']
        sCondition = dInstruction['condition']
        lCondition = sCondition.split(' ')
        lInstruction = sIntruction.split(' ')
        dInstruction['instruction'] = {
            'register': lInstruction[0],
            'operator': lInstruction[1],
            'offset': lInstruction[2]}
        dInstruction['condition'] = {
            'register': lCondition[0],
            'comparator': lCondition[1],
            'value': lCondition[2]}
        lInstructions.append(dInstruction)

    # Return a list of instructions
    return lInstructions


def createRegisters(lInstructions):
    """
        Helper function to create register set
        Inputs : lInstructions (list) - List of all instructions of program
    """
    lRegisters = []

    # Making a list of every register used
    # Conditions are not checked because the inputs does not contain any
    # register used for condition and not used in the instructions
    for dInstruction in lInstructions:
        sCurrentRegister = dInstruction['instruction']['register']
        lRegisters.append(sCurrentRegister)

    # Creating a set containing each register only once
    setRegisters = set(lRegisters)

    # Creating a dictionary of registers and initializing each at 0 value
    dRegisters = {}
    for sRegister in setRegisters:
        dRegisters[sRegister] = 0
    return dRegisters


def evaluateCondition(dCondition, dRegisters):
    """
        Function to evaluate the conditions of the current instruction
        Inputs : dCondition (dictionary) - Object representing the condition
            to evaluate
                dRegisters (dictionary) - Object representing the memory of
            the program, with register names and the values they contain
        Outputs : True or False given the logical value of condition
    """

    # Dictionary associating callable functions to operators
    dOperators = {'<': less,
                  '<=': lessOrEqual,
                  '>': greater,
                  '>=': greaterOrEqual,
                  '==': equal,
                  '!=': notEqual}

    # Condition is broken down in variables
    sRegister = dCondition['register']
    sComparator = dCondition['comparator']
    # int casting because boolean expressions had some unexpected results like
    # 1 >= 1 == False, for some reason
    iValue = int(dCondition['value'])
    return dOperators[sComparator](dRegisters, sRegister, iValue)


def less(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] < iValue)


def greater(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] > iValue)


def lessOrEqual(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] <= iValue)


def greaterOrEqual(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] >= iValue)


def equal(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] == iValue)


def notEqual(dRegisters, sRegister, iValue):
    return (dRegisters[sRegister] != iValue)


def executeInstruction(lInstructions, dRegisters):
    """
        Function to execute the current instruction
    """

    # Current instruction is dequeued and broken down
    dTotalInstruction = lInstructions.pop(0)
    dInstruction = dTotalInstruction['instruction']
    dCondition = dTotalInstruction['condition']

    # Condition is evaluated
    bCondition = evaluateCondition(dCondition, dRegisters)
    # And instruction is executed only if condition is True
    if bCondition:
        if dInstruction['operator'] == 'inc':
            dRegisters[dInstruction['register']] += int(dInstruction['offset'])
        else:
            dRegisters[dInstruction['register']] -= int(dInstruction['offset'])
    return lInstructions, dRegisters


def main():
    lInstructions = recoverInstructions()
    dRegisters = createRegisters(lInstructions)
    iMaxValue = 0
    while lInstructions != []:
        lInstructions, dRegisters = executeInstruction(
            lInstructions, dRegisters)
        iMaxValue = max(iMaxValue, max(dRegisters.values()))

    lRegistersValues = dRegisters.values()
    print('Final max value = ' + str(max(lRegistersValues)))
    print('All time  max value = ' + str(iMaxValue))
    return


if __name__ == '__main__':
    main()
