import sys

doubles = 0
triples = 0

with open(sys.argv[1], 'r') as f:
    for line in f:
        chardict = {}
        aDouble = False
        for char in line:
            if char in chardict:
                chardict[char] += 1
            else:
                chardict[char] = 1
        if 3 in chardict.values():
            triples += 1
        if 2 in chardict.values():
            doubles += 1
print("Doubles : {}, Triples : {}".format(doubles, triples))
print(doubles * triples)