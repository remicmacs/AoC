#! /usr/bin/python2

import sys


def recoverPassphrases():
    lPassphrases = []

    for line in sys.stdin:
        lPassword = line.split(' ')
        lPassword = [password.replace('\n', '') for password in lPassword]
        lPassphrases.append(lPassword)
    return lPassphrases


def checkIfValidPassphrase(lPassword):
    iLen = len(lPassword)
    iIndex = 0

    while iIndex < iLen:
        sCurrentPw = lPassword.pop(iIndex)

        if sCurrentPw in lPassword:
            lPassword.insert(iIndex, sCurrentPw)
            return False

        if checkIfAnagram(sCurrentPw, lPassword):
            lPassword.insert(iIndex, sCurrentPw)
            return False

        lPassword.insert(iIndex, sCurrentPw)
        iIndex += 1
    return True


def countCharsOfWords(sWord):
    dChars = {}

    for cChar in sWord:
        if cChar in dChars:
            dChars[cChar] += 1
        else:
            dChars[cChar] = 1
    return dChars


def checkIfAnagram(sCurrentPw, lPassword):
    dCharsOfPass = countCharsOfWords(sCurrentPw)

    lCharsOfPws = [countCharsOfWords(pw) for pw in lPassword]

    if dCharsOfPass in lCharsOfPws:
        return True
    return False


def countHowManyValidPassphrases(lPassphrases):
    iTotal = 0
    for lPassword in lPassphrases:
        print('Current passphrase :')
        print(lPassword)
        bIsValid = checkIfValidPassphrase(lPassword)
        if bIsValid:
            print('is valid')
            iTotal += 1
        else:
            print('is not valid')
    return iTotal


def main():
    lPassphrases = recoverPassphrases()
    print(lPassphrases)
    print(countHowManyValidPassphrases(lPassphrases))
    return 0


if __name__ == '__main__':
    main()
