include("../get_input.jl")

function preprocess_input(input)
    numbers = parse.(Int, reduce(vcat, split.(reduce(vcat, split.(input, " -> ")), ",")))
    num_lines = Int(length(numbers) / 4)
    xyxy = reshape(numbers, (4, num_lines))'
    return xyxy
end

function test()
    input = read_input("test.txt")
    xyxy = preprocess_input(input)
    println(xyxy)
end

test()

# input = read_input()
# xyxy = preprocess_input(input)
