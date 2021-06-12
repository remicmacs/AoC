#! /usr/bin/python2


import sys


def checksumSpreadsheet(lSpreadSheet):
    iSum = 0

    for lLine in lSpreadSheet:
        iSum += checksumLine(lLine)

    return iSum


def checksumLine(lLine):
    lLine.sort()
    iMin = lLine[0]
    iMax = lLine[-1]
    return iMax - iMin


def recoverSpreadsheet():
    lSpreadSheet = []

    for line in sys.stdin:
        lIntegerLine = line.split('\t')
        lIntegerLine = [int(element) for element in lIntegerLine]
        lSpreadSheet.append(lIntegerLine)
    return lSpreadSheet


def evenlyDivisible(lLine):
    iLen = len(lLine)
    iCurrentInteger = 0
    while iCurrentInteger < iLen:
        iComparedInteger = iCurrentInteger + 1
        while iComparedInteger < iLen:
            if lLine[iCurrentInteger] % lLine[iComparedInteger] == 0:
                return lLine[iCurrentInteger] / lLine[iComparedInteger]
            if lLine[iComparedInteger] % lLine[iCurrentInteger] == 0:
                return lLine[iComparedInteger] / lLine[iCurrentInteger]
            iComparedInteger += 1
        iCurrentInteger += 1


def sumEvenlyDivisible(lSpreadSheet):
    iSum = 0

    for lLine in lSpreadSheet:
        iSum += evenlyDivisible(lLine)
    return iSum


def main():
    lSpreadSheet = recoverSpreadsheet()
    print(lSpreadSheet)
    print(checksumSpreadsheet(lSpreadSheet))
    print(sumEvenlyDivisible(lSpreadSheet))
    return 0


if __name__ == '__main__':
    main()
