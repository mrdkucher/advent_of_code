import numpy as  np
from scipy.signal import convolve2d


def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()


def create_matrix(text):

    arr = np.zeros((10, 10))
    for i, line in enumerate(text):
        for j, char in enumerate(line.rstrip('\n')):
            arr[i, j] = int(char)
    return arr


def single_step(matrix):
    matrix += 1

    mask = matrix > 9

    kernel = np.ones((3, 3))
    kernel[1, 1] = 0

    counted_mask = mask
    while np.sum(mask) > 0:
        output = convolve2d(mask, kernel, mode='same')
        matrix = matrix + output
        mask = (matrix > 9) ^ counted_mask
        counted_mask = (matrix > 9)

    mask = matrix > 9
    num_flashes = np.sum(mask)
    matrix *= (1 - mask)

    return matrix, num_flashes


def run_steps(matrix, count=100):
    total_flashes = 0
    if count < 0:
        count = 0
        while not (matrix == 0).all():
            matrix, num_flashes = single_step(matrix)
            count += 1
        return count

    for step in range(count):
        matrix, num_flashes = single_step(matrix)
        total_flashes += num_flashes

    return total_flashes


def test():
    input = read_input("test.txt")
    start_matrix = create_matrix(input)
    start_matrix2= np.copy(start_matrix)

    total_flashes = run_steps(start_matrix, 100)

    assert total_flashes == 1656

    steps = run_steps(start_matrix2, -1)
    assert steps == 195


if __name__ == "__main__":
    test()
    text = read_input()
    matrix = create_matrix(text)
    matrix2 = np.copy(matrix)

    total_flashes = run_steps(matrix, 100)
    print("TOTAL FLASHES: ", total_flashes)
    steps = run_steps(matrix2, -1)
    print('SYNC STEPS:', steps)
