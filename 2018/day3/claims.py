import sys
import numpy as np

# Creating unclaimed fabric.
fabric = np.zeros((1000, 1000), dtype=int)

claims = []
claims.insert(0, ((0,0),(0,0)))

overlapping_claims = np.zeros(1348, dtype=bool)
overlapping_claims[0] = True

fabric_layers = np.empty((1000, 1000), dtype=list)

with open(sys.argv[1], 'r') as f:
    for line in f:
        # Reading one entry (discarding the `@` char)
        claim_id, _, start, span = line.rstrip('\n').split()

        claim_id = int(claim_id.lstrip("#"))

        # Turning start in tuple of indices
        start = start.rstrip(':').split(',')
        start = (int(start[0]), int(start[1]))

        # Turning span in tuple of int
        span = span.split('x')
        span = (int(span[0]), int(span[1]))

        # Building boundary indices of claim
        x = start[0]
        xx = start[0] + span[0]

        y = start[1]
        yy = start[1] + span[1]

        # Incrementing claimed square inches
        fabric[x:xx, y:yy] += 1

        slice = fabric_layers[x:xx, y:yy]

        # Storing a list of claims on every square inch of the fabric.
        # A claimed square has a non empty array in its corresponding
        #   cell, and an unclaimed square has [].
        for index, square_inch in np.ndenumerate(slice):
            if square_inch is None:
                slice[index] = [claim_id]
            else :
                if (len(square_inch) >= 1):
                    overlapping_claims[claim_id] = True
                    for other_claim_id in square_inch:
                        overlapping_claims[other_claim_id] = True
                square_inch.append(claim_id)

        claim_dict = {
            "id": claim_id,
            "top_left" :(x,y),
            "down_right": (xx,yy)
        }

        claims.insert(claim_id, ((x,y), (xx,yy)))

        # check_overlap(claim_dict, claims, overlapping_claims)

        # Counting overlap square inches
overlap = (fabric >= 2).sum()

# print(fabric[0:10, 0:10])
print("{} square inches of overlap".format(overlap))

# Find only non overlapping claim.
# print(overlapping_claims)
non_overlapping = np.where(overlapping_claims == False)[0]
print("Indices of non overlapping claims : {}".format(
    non_overlapping
    )
)
