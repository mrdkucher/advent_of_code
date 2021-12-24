def find_sum(numbers, target):
    number_set = set(numbers)
    for number in numbers:
        if target - number in number_set:
            return number * (target - number)
    return 0

def find_3sum(numbers, target):
    number_set = set(numbers)
    for i in range(len(numbers)):
        for j in range(i, len(numbers)):
            if target - numbers[i] - numbers[j] in number_set:
                return numbers[i]*numbers[j]*(target - numbers[i] - numbers[j])

def test_find_sum():
    numbers = [1721, 979, 366, 299, 675, 1456]
    assert find_sum(numbers, 2020) == 514579
    assert find_3sum(numbers, 2020) == 241861950

if __name__ == '__main__':
    test_find_sum()

    with open('input.txt', 'r') as f:
        lines = f.readlines()
    lines = [int(line.strip('\n')) for line in lines]
    product = find_sum(lines, 2020)
    print('Product:', product)
    product3 = find_3sum(lines, 2020)
    print('Product of 3:', product3)
