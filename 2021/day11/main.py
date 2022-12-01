import numpy as  np
from scipy.signal import convolve2d


def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()


def create_matrix(text):

    arr = np.zeros((10, 10))
    for i, line in enumerate(text):
        # print('> ', line.rstrip('\n'))
        for j, char in enumerate(line.rstrip('\n')):
            arr[i, j] = int(char)
    # print(arr)
    return arr


def single_step(matrix):
    matrix += 1

    mask = matrix > 9
    # print("INIT > 9")
    # print(mask.astype(int))

    kernel = np.ones((3, 3))
    kernel[1, 1] = 0


    # print("KERNEL\n", kernel)

    counted_mask = mask
    while np.sum(mask) > 0:
        output = convolve2d(mask, kernel, mode='same')
        # print("FILTERED OUTPUT\n", output)
        matrix = matrix + output
        mask = (matrix > 9) ^ counted_mask
        # print('new mask:\n', mask.astype(int))
        counted_mask = (matrix > 9)
        # print('counted\n', counted_mask.astype(int))
        # print(np.sum(mask))

    mask = matrix > 9
    # print("NEW MATRIX:", matrix)

    # print("NEW > 9\n", mask.astype(int))

    num_flashes = np.sum(mask)

    matrix *= (1 - mask)
    # print("AFTER STEP\n", matrix)
    # print("================================================================")

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
    # input = read_input("test2.txt")
    # start_matrix = create_matrix(input)

    # total_flashes = run_steps(start_matrix, 3)

    # assert total_flashes == 9

    input = read_input("test.txt")
    start_matrix = create_matrix(input)
    start_matrix2= np.copy(start_matrix)

    total_flashes = run_steps(start_matrix, 100)
    # print("TOTAL FLASHES: ", total_flashes)

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



# input = read_input()
# start_matrix = create_matrix(input)
