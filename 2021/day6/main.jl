include("../get_input.jl")

function preprocess_input(input)
    numbers = parse.(Int, split(input, ","))
    return numbers
end

function lanternfish_eff(fish, num_steps=80)
    fish_dict = Dict()
    for f in range(1, 8)
        fish_dict[f] = sum(fish .== f)
    end

    for step in range(1, num_steps)
        spawn = 0
        if 0 in keys(fish_dict)
            spawn = fish_dict[0]
        end

        for i in range(1, 8)
            fish_dict[i-1] = fish_dict[i]
        end

        fish_dict[8] = spawn
        fish_dict[6] += spawn
    end

    total = 0
    for f in range(0, 8)
        total += fish_dict[f]
    end
    return total
end

function test()
    input = read_input("test.txt")[1]
    fish = preprocess_input(input)
    num_fish = lanternfish_eff(fish, 18)
    @assert num_fish == 26
    num_fish = lanternfish_eff(fish)
    @assert num_fish == 5934
    num_fish = lanternfish_eff(fish, 256)
    @assert num_fish == 26984457539
end

test()

input = read_input()[1]
fish = preprocess_input(input)
num_fish = lanternfish_eff(fish)
println("Num fish: ", num_fish)
num_fish = lanternfish_eff(fish, 256)
println("Num fish: ", num_fish)
