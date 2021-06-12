import sys
import copy
ids = []
with open(sys.argv[1], 'r') as f:
    for line in f:
        ids.append(line.rstrip('\n'))

print(ids)

almostTheSame = ("", "")

for id in ids:
    for other in ids:
        diff = 0
        for i in range(len(id)):
            if id[i] != other[i]:
                diff += 1
            if diff > 1:
                break
        print("Difference between \'{}\' and \'{}\' is {}".format(id, other, diff))
        if diff == 1:
            almostTheSame = (id, other)
            break
    if almostTheSame != ("", ""):
        break

print(almostTheSame)
for i in range(len(almostTheSame[0])):
    if almostTheSame[0][i] != almostTheSame[1][i]:
        print(almostTheSame[0][:i] + almostTheSame[0][i+1:])
        break