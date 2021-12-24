import numpy as np


def num_increasing(lines):
    diffs = lines[1:] - lines[:-1]
    return sum(diffs > 0)

def test_num_increasing():
    lines = np.array([1, 2, 3, 4, 5])
    assert num_increasing(lines) == 4
    lines = np.array([5, 4, 3, 2, 1])
    assert num_increasing(lines) == 0
    lines = np.array([1, 5, 4, 2, 3])
    assert num_increasing(lines) == 2
    lines = np.array([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
    assert num_increasing(lines) == 7

def sliding_window(lines, length):
    window = np.ones(length)
    return np.convolve(lines, window, mode='valid')

def test_sliding_window():
    lines = np.array([1, 2, 3, 4, 5])
    lines = sliding_window(lines, 3) 
    assert np.all(lines == np.array([6, 9, 12]))
    assert num_increasing(lines) == 2
    lines = np.array([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
    lines = sliding_window(lines, 3)
    assert np.all(lines == np.array([607, 618, 618, 617, 647, 716, 769, 792]))
    assert num_increasing(lines) == 5
    
if __name__ == '__main__':
    test_num_increasing()
    test_sliding_window()
    with open('input.txt', 'r') as f:
        lines = f.readlines()
    
    lines = np.array([int(line.strip('\n')) for line in lines])
    solution = num_increasing(lines)
    print('Solution 1:', solution)
    lines = sliding_window(lines, 3)
    solution = num_increasing(lines)
    print('Solution 2:', solution)
