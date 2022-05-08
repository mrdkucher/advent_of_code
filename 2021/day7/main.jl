include("../get_input.jl")
using DataStructures

function preprocess_input(input)
    numbers = parse.(Int, split(input, ","))
    return numbers
end

function align_fish(positions, verbose=false)
    sort!(positions)
    middle = sum(positions) ÷ length(positions)
    start = positions[1]

    index = 1
    lt_sum = 0
    gt_sum = length(positions)
    cost = sum(positions .- start)
    min_cost = Inf
    best_pos = 0

    start += 1
    decreasing = true
    while start <= positions[length(positions)]
        if verbose
            println("START:", start)
        end
        while (index <= length(positions)) & (positions[index] < start)
            lt_sum += 1
            gt_sum -= 1
            index += 1
            # if verbose
            #     println(lt_sum)
            #     println(gt_sum)
            #     println()
            # end
        end
        cost = cost + lt_sum - gt_sum
        if cost < min_cost
            min_cost = cost
            best_pos = start
        else
            decreasing = false
        end

        if verbose
            println("COST:", cost)
            println()
        end
        start += 1
    end

    return min_cost

end

distance2cost = Dict()

function get_cost(distance)
    if distance == 0
        return 0 
    end

    if distance in keys(distance2cost)
        return distance2cost[distance]
    end

    cost = get_cost(distance - 1) + distance
    distance2cost[distance] = cost
    return cost
end

function align_fish2(positions, verbose=false)
    frequency = DataStructures.DefaultDict(0)
    costs = DataStructures.DefaultDict(0)

    for position in positions
        frequency[position] += 1
    end

    positions = collect((Set(positions)))
    sort!(positions)
    start = positions[1]

    index = 1
    lt_sum = 0

    total_cost = 0
    for key in keys(frequency)
        distance = key - start
        if verbose
            println("DISTANCE: ", distance, " COST: ", get_cost(distance))
        end
        costs[key] = get_cost(distance)
        total_cost += frequency[key] * costs[key]
    end


    min_cost = total_cost
    best_pos = start

    start += 1
    decreasing = true
    while start <= positions[length(positions)]
        if verbose
            println("START:", start)
        end
        total_cost = 0
        for key in keys(costs)
            costs[key] += start - key
            if key >= start
                costs[key] -= 1
            end
            if verbose
                println("KEY: ", key, " COST: ", costs[key])
            end
            total_cost += costs[key] * frequency[key]
        end
        if total_cost < min_cost
            min_cost = total_cost
            best_pos = start
        else
            decreasing = false
        end

        if verbose
            println("COST: ", total_cost)
            println()
        end
        start += 1
    end

    return min_cost

end

function test()
    input = read_input("test.txt")[1]
    h_pos = preprocess_input(input)
    min_cost = align_fish(h_pos)
    @assert min_cost == 37
    min_cost = align_fish2(h_pos)
    @assert min_cost == 168
end

test()

input = read_input()[1]
h_pos = preprocess_input(input)
min_cost = align_fish(h_pos)
println("min_cost: ", min_cost)
min_cost = align_fish2(h_pos)
println("min_cost: ", min_cost)
