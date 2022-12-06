from collections import defaultdict
import copy
import logging

def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()

def _is_large_cave(cave_code: str):
    if cave_code.upper() == cave_code:
        return True
    return False

def create_adj_dict(text):
    adj_dict = defaultdict(set)
    for line in text:
        start, end = line.split('-')
        start, end = start.strip(), end.strip()
        adj_dict[start].add(end)
        adj_dict[end].add(start)

    return adj_dict


def find_paths(text):
    adj_dict = create_adj_dict(text)

    started_paths = [['start']]
    finished_paths = []

    while len(started_paths) > 0:
        old_started_paths = copy.copy(started_paths)
        started_paths = []


        # add all viable adjacent nodes to each path
        for path_stub in old_started_paths:
            # grab current loc
            current_location = path_stub[-1]
            logging.debug(f'CURRENT_PATH STUB: {path_stub}')

            # add any viable adjacent nodes
            adjacent_nodes = adj_dict[current_location]
            # print('ADJ LOCATIONS:', adjacent_nodes)
            for adj_node in adjacent_nodes:
                logging.debug(f'\tNODE: {adj_node}')
                if _is_large_cave(adj_node) or adj_node not in path_stub:
                    updated_path_stub = copy.copy(path_stub)
                    updated_path_stub.append(adj_node)

                    logging.debug(f'\t\tNEW PATH: {updated_path_stub}')
                    if adj_node != 'end':
                        started_paths.append(updated_path_stub)
                    else:
                        finished_paths.append(updated_path_stub)

    return finished_paths

def _can_visit_small_cave(node_name, path_stub):
    if node_name == 'start':
        return False

    if node_name == 'end':
        return True

    # check if node exists twice in list
    small_cave_counts = defaultdict(int)
    for node in path_stub:
        if not _is_large_cave(node):
            small_cave_counts[node] += 1

    if small_cave_counts[node_name] == 0:
        return True

    # can only revisit a cave if no other caves have been visited twice
    if small_cave_counts[node_name] == 1:
        for node, count in small_cave_counts.items():
            if count == 2 and not _is_large_cave(node):
                return False
        return True
    if small_cave_counts[node_name] == 2:
        return False

    return False

def find_long_paths(text):
    adj_dict = create_adj_dict(text)

    started_paths = [['start']]
    finished_paths = []

    while len(started_paths) > 0:
        old_started_paths = copy.copy(started_paths)
        started_paths = []

        # add all viable adjacent nodes to each path
        for path_stub in old_started_paths:
            # grab current loc
            current_location = path_stub[-1]

            # add any viable adjacent nodes
            adjacent_nodes = adj_dict[current_location]
            for adj_node in adjacent_nodes:
                if _is_large_cave(adj_node) or _can_visit_small_cave(adj_node, path_stub):
                    updated_path_stub = copy.copy(path_stub)
                    updated_path_stub.append(adj_node)

                    if adj_node != 'end':
                        started_paths.append(updated_path_stub)
                    else:
                        finished_paths.append(updated_path_stub)

    return finished_paths


def test():
    input = read_input("test.txt")

    logging.getLogger().setLevel(logging.DEBUG)
    total_paths = find_paths(input)
    logging.getLogger().setLevel(logging.WARNING)
    assert len(total_paths) == 10
    all_long_paths = find_long_paths(input)
    assert len(all_long_paths) == 36

    input = read_input("test2.txt")
    total_paths = find_paths(input)
    assert len(total_paths) == 19
    all_long_paths = find_long_paths(input)
    assert len(all_long_paths) == 103

    input = read_input("test3.txt")
    total_paths = find_paths(input)
    assert len(total_paths) == 226
    all_long_paths = find_long_paths(input)
    assert len(all_long_paths) == 3509


if __name__ == "__main__":
    test()
    text = read_input()
    total_paths = find_paths(text)
    print('PATHS:', len(total_paths))
    all_long_paths = find_long_paths(text)
    print('LONG PATHS:', len(all_long_paths))
