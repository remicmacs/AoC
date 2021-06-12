#! /usr/bin/python2

import sys


def recoverInput():
    """
        Function to recover list of values
    """
    lListOfIntegers = []
    sLine = raw_input()
    lListOfIntegers = [int(element) for element in sLine]
    return lListOfIntegers


def executeReverseCaptchaV1(lListOfIntegers):
    iCounter = 0
    iIndex = 0
    iLenList = len(lListOfIntegers)

    while iIndex < iLenList:
        if lListOfIntegers[iIndex-1] == lListOfIntegers[iIndex]:
            iCounter += lListOfIntegers[iIndex-1]
        iIndex += 1

    return iCounter


def executeReverseCaptchaV2(lListOfIntegers):
    iCounter = 0
    iIndex = 0
    iLenList = len(lListOfIntegers)

    while iIndex < iLenList:
        iOtherIndex = (iIndex + (iLenList / 2)) % iLenList
        if lListOfIntegers[iIndex] == lListOfIntegers[iOtherIndex]:
            iCounter += lListOfIntegers[iIndex]
        iIndex += 1

    return iCounter


def main():
    lListOfIntegers = recoverInput()
    iResult = executeReverseCaptchaV2(lListOfIntegers)
    print(iResult)
    return iResult


if __name__ == '__main__':
    main()
