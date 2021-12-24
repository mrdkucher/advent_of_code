function count_trees(input, down=1, right=3)
    count = 0

    position = 0
    for r in 1:down:length(input)
        row = input[r]
        if row[position + 1] == '#'
            count += 1
        end
        position = (position + right) % length(row)
    end

    return count
end

function test_count_trees()
    input = ["..##.......", "#...#...#..", ".#....#..#.", "..#.#...#.#", ".#...##..#.", "..#.##.....", ".#.#.#....#", ".#........#", "#.##...#...", "#...##....#", ".#..#...#.#"]
    @assert count_trees(input) == 7
    @assert count_trees(input)*count_trees(input, 1, 1)*count_trees(input, 1, 5)*count_trees(input, 1, 7)*count_trees(input, 2, 1) == 336
end

test_count_trees()

include("../get_input.jl")

input = read_input()
num_trees = count_trees(input)
println("Number of trees: ", num_trees)
prod_num_trees = count_trees(input)*count_trees(input, 1, 1)*count_trees(input, 1, 5)*count_trees(input, 1, 7)*count_trees(input, 2, 1)
println("Product of Number of trees: ", prod_num_trees)
