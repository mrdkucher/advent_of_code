import logging
import numpy as np

def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()

def construct_paper(text):
    instructions = []
    dots = []
    line_idx = 0
    while line_idx < len(text) and text[line_idx] != '\n':
        coords = [int(val) for val in text[line_idx].strip().split(',')]
        dots.append(coords)
        line_idx +=1
    line_idx += 1
    while line_idx < len(text):
        instructions.append(text[line_idx].strip())
        line_idx +=1
    logging.debug(f' DOTS: {dots}')
    logging.debug(f' INSTRUCTIONS {instructions}')

    return np.array(dots), instructions

def dot_visualizer(dots, print_msg=False):
    x_max, y_max = np.max(dots, axis=0)
    x_size, y_size = x_max + 1, y_max + 1
    grid = np.chararray((y_size, x_size), unicode=True)
    grid[:] = '.'
    for dot in dots:
        i, j = dot
        grid[j, i] = '#'

    lines = []
    for line in grid:
        lines.append(''.join(line))
    msg = '\n'.join(lines)
    if print_msg:
        print(msg)
    else:
        logging.debug(f'\n{msg}')


def fold_paper(dots, instr, max_instr = None):
    dots_ = np.copy(dots)
    for instr_ctr, line in enumerate(instr):
        if max_instr is not None and instr_ctr == max_instr:
            return dots_
        fold_num = line.split(' ')[-1]
        axis, num = fold_num.split('=')
        num = int(num)
        assert axis in ['x', 'y']
        ax_idx = 1 if axis == 'y' else 0

        # Function to fold dots: use abs
        dots_[:, ax_idx] = num - abs(dots_[:, ax_idx] - num)

        logging.debug(f'    INSTR: {axis}, {num}')
        dot_visualizer(dots_)
    return dots_

def count_dots(dots):
    dots_set = set()
    for coord in dots:
        dots_set.add(tuple(coord))
    return len(dots_set)

def test():
    input = read_input("test.txt")

    logging.getLogger().setLevel(logging.DEBUG)
    dots, instr = construct_paper(input)
    dot_visualizer(dots)
    new_dots = fold_paper(dots, instr, 1)
    num_dots = count_dots(new_dots)
    assert num_dots == 17
    logging.getLogger().setLevel(logging.WARNING)


if __name__ == "__main__":
    test()
    text = read_input()
    dots, instr = construct_paper(text)
    dot_visualizer(dots)
    new_dots = fold_paper(dots, instr, 1)
    num_dots = count_dots(new_dots)
    print('VISIBLE DOTS:', num_dots)
    message = fold_paper(dots, instr)
    print('MESSAGE:')
    dot_visualizer(message, True)
