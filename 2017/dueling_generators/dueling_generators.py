#! /usr/bin/python2

# Generators factors
iFactorA = 16807
iFactorB = 48271


def produceNext(iPrevious, iFactor, iKey):
    """
        Function to produce next number. v2 with a key to select if number is
        fit to be returned
    """
    iQuotient = 2147483647
    iIntermediary = iPrevious * iFactor
    iNext = iIntermediary % iQuotient

    # v2 addendum
    if iNext % iKey != 0:
        return produceNext(iNext, iFactor, iKey)
    return iNext


def producePair(iStartA, iStartB):
    """
        Function to produce a corresponding pair of numbers
    """
    iNewA = produceNext(iStartA, iFactorA, 4)
    iNewB = produceNext(iStartB, iFactorB, 8)
    return (iNewA, iNewB)


def convertToBinaryString(iInteger):
    """
        Function that returns an interger in its binary value on 32 bits
    """
    binInt = bin(iInteger)
    sBin = str(binInt).lstrip('0b').zfill(32)
    return sBin


def matchLowest(iNumberA, iNumberB):
    """
        Function to compare the 16 lowest bits of binary string numbers
    """
    sBinA = convertToBinaryString(iNumberA)
    sBinB = convertToBinaryString(iNumberB)

    sSubStrA = sBinA[-16:]
    sSubStrB = sBinB[-16:]
    return sSubStrA == sSubStrB


def calculateMatches(iStartA, iStartB):
    """
        Function to calculate the number of matches over 5 million rounds
    """
    iMatches = 0
    for _ in range(5000000):
        iStartA, iStartB = producePair(iStartA, iStartB)
        if matchLowest(iStartA, iStartB):
            iMatches += 1

    return iMatches


def main():
    iStartA = 116
    iStartB = 299

    print(calculateMatches(iStartA, iStartB))
    return 0


if __name__ == '__main__':
    main()
