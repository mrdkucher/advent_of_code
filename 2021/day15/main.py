import logging
import numpy as np
from collections import deque

def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()

def construct_matrix(text):
    # rows, cols = len(text), len(text[0])

    matrix = []
    for text_row in text:
        row = []
        for char in text_row.strip():
            row.append(int(char))
        matrix.append(row)
    logging.debug(f' MATRIX: \n{matrix}')
    return matrix

def find_valid_new_locations(i, j, rows, cols):
    new_locations = []
    if i > 0:
        new_locations.append((i - 1, j))
    if i < (rows - 1):
        # go down
        new_locations.append((i + 1, j))
    if j > 0:
        # go left
        new_locations.append((i, j - 1))
    if j < (cols - 1):
        # go right
        new_locations.append((i, j + 1))
    return new_locations

def construct_larger_matrix(matrix, repeat=5, mod=10):
    matrix = np.array(matrix)
    rows, cols = matrix.shape
    increments = np.array([i for i in range(repeat)])
    row_increments = np.repeat(increments, rows)
    col_increments = np.repeat(increments, cols)
    increment_matrix = np.add.outer(row_increments, col_increments)
    larger_matrix = np.tile(matrix, [5, 5]) + increment_matrix

    return larger_matrix % mod + larger_matrix // 10

def compute_lowest_risk_path(matrix):
    matrix = np.array(matrix)
    running_cost = np.zeros_like(matrix) - 1
    running_cost[0, 0] = 0

    rows, cols = matrix.shape

    q = deque()
    q.append((0, 0))
    while len(q) > 0:
        i, j = q.popleft()
        cur_risk = running_cost[i, j]

        logging.debug(f'At location ({i}, {j}) with risk: {cur_risk}')

        new_locations = find_valid_new_locations(i, j, rows, cols)
        logging.debug(f'    Found new locations: {new_locations}')

        found_alt_route = False
        for new_loc in new_locations:
            new_i, new_j = new_loc
            if running_cost[new_i, new_j] == -1:
                # unvisited, cannot use this cost
                continue
            alt_cur_risk = running_cost[new_i, new_j] + matrix[i, j]
            if alt_cur_risk < cur_risk:
                logging.debug(f'    Found alternate path. cur risk {cur_risk}, alt risk: {alt_cur_risk}')
                # found less risky path, redo search with all neighbors
                found_alt_route = True
                cur_risk = alt_cur_risk
                running_cost[i, j] = alt_cur_risk
        if found_alt_route:
            q.append((i, j))
            continue

        for new_loc in new_locations:
            new_i, new_j = new_loc
            new_risk = cur_risk + matrix[new_i, new_j]
            if running_cost[new_i, new_j] == -1 or new_risk < running_cost[new_i, new_j]:
                logging.debug(f'    Updating risk for location: ({new_i}, {new_j}) to {new_risk}')
                running_cost[new_i, new_j] = new_risk
                q.append((new_i, new_j))

    return running_cost[-1, -1]

def test():
    text = read_input("test.txt")

    matrix = construct_matrix(text)
    logging.getLogger().setLevel(logging.DEBUG)

    risk = compute_lowest_risk_path(matrix)
    assert risk == 40, f'Got {risk}, expected 40'
    logging.getLogger().setLevel(logging.WARNING)

    larger_matrix = construct_larger_matrix(matrix)
    risk = compute_lowest_risk_path(larger_matrix)
    assert risk == 315, f'Got {risk}, expected 315'


if __name__ == "__main__":
    test()
    text = read_input()
    matrix = construct_matrix(text)
    risk = compute_lowest_risk_path(matrix)
    print('RISK:', risk)
    larger_matrix = construct_larger_matrix(matrix)
    risk = compute_lowest_risk_path(larger_matrix)
    print('RISK:', risk)
