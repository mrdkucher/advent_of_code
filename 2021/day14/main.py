from collections import defaultdict


def read_input(fname="input.txt"):
    with open(fname, "r") as f:
        return f.readlines()


def parse_inputs(text):
    template = ""
    substitutions = {}
    line_idx = 0
    while line_idx < len(text) and text[line_idx] != '\n':
        template = text[line_idx].strip()
        line_idx += 1
    line_idx += 1
    while line_idx < len(text):
        pair, insertion = text[line_idx].strip().split(' -> ')
        substitutions[pair] = insertion
        line_idx +=1

    pairs = defaultdict(int)
    for i in range(len(template) - 1):
        pairs[template[i:i+2]] += 1

    counts = defaultdict(int)
    for letter in template:
        counts[letter] += 1
    return pairs, counts, substitutions


def pair_insertion(pairs, counts, subs):
    new_pairs = defaultdict(int)
    for pair, count in pairs.items():
        letter = subs.get(pair, '')
        counts[letter] += count
        first, second = pair
        new_pairs[first + letter] += count
        new_pairs[letter + second] += count

    return new_pairs


def check_str(gold_str, counts):
    gold_counts = defaultdict(int)
    for letter in gold_str:
        gold_counts[letter] += 1
    
    for key, value in gold_counts.items():
        assert value == counts[key], f'{key} => expected {value} got {counts[key]}'


def test():
    input = read_input("test.txt")

    pairs, counts, substitutions = parse_inputs(input)

    for i in range(10):
        pairs = pair_insertion(pairs, counts, substitutions)

        # NNCB -> pairs = (NN), (NC), (CB)
        # new pairs -> (NC), (CN), (NB), (BC), (CH), (HB)
        if i == 0:
            check_str("NCNBCHB", counts)
        elif i == 1:
            check_str("NBCCNBBBCBHCB", counts)
        elif i == 2:
            check_str("NBBBCNCCNBBNBNBBCHBHHBCHB", counts)
        elif i == 3:
            check_str("NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB", counts)
    diff = max(counts.values()) - min(counts.values())
    assert diff == 1588

    for i in range(10, 40):
        pairs = pair_insertion(pairs, counts, substitutions)

    diff = max(counts.values()) - min(counts.values())
    assert diff == 2188189693529


if __name__ == '__main__':
    test()
    text = read_input()
    pairs, counts, substitutions = parse_inputs(text)
    for i in range(10):
        pairs = pair_insertion(pairs, counts, substitutions)
    diff = max(counts.values()) - min(counts.values())
    print('DIFF:', diff)
    for i in range(10, 40):
        pairs = pair_insertion(pairs, counts, substitutions)
    diff = max(counts.values()) - min(counts.values())
    print('DIFF 40:', diff)
