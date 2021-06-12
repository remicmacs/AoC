import sys
import numpy as np

def manhattan_distance(source, target):
    x1, y1 = source
    x2, y2 = target

    dist = abs(x2 - x1) + abs(y2 - y1)

    return dist

# Populating array of coordinates.
coords = []
with open(sys.argv[1], mode='r') as f:
    for line in f:
        line = line.split(', ')
        coord = (int(line[1]), int(line[0]))
        coords.append(coord)

# Finding the down-right corner of the grid
coords = sorted(coords, key=lambda x: x[0])
max_coordx = coords[-1]
coords = sorted(coords, key=lambda x: x[1])
max_coordy = coords[-1]
max_coord = (max_coordx[0], max_coordy[1])

# Creating grid from (0,0) to the farthest point.
shape = (max_coord[0], max_coord[1])
indices_grid = np.zeros(shape, dtype=int)
region_grid = np.zeros(shape, dtype=bool)

for index, square in np.ndenumerate(indices_grid):
    # Process all man. dist. to coordinates.
    dists = [manhattan_distance(index, coord) for coord in coords]

    min_dist = min(dists)
    min_index = dists.index(min_dist)

    sum_dists = sum(dists)
    region_grid[index] = sum_dists < 10000

    # If the min. is unique, the square is claimed
    dists = dists[:min_index] + dists[min_index+1:]
    if min_dist in dists:
        indices_grid[index] = -1
    else:
        indices_grid[index] = min_index

# Processing territory sizes according grid of indices.
# Infinite territories are set to -1.
territories = [0] * len(coords)
for index, square in np.ndenumerate(indices_grid):
    if (indices_grid[index] == -1
        or territories[square] == -1
        or (0 in index or index[0] == max_coord[0] or index[1] == max_coord[1])
    ):
        territories[square] = -1
    else:
        territories[square] += 1

print(max(territories))
count = region_grid.sum()
print(count)

