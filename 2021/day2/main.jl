function plan_course(input)
    horizontal = 0
    depth = 0

    for row in input
        direction, amount = split(row, ' ')
        amount = parse(Int64, amount)
        if direction == "forward"
            horizontal += amount
        elseif direction == "up"
            depth -= amount
        elseif direction == "down"
            depth += amount
        end
    end

    return horizontal*depth
end

function plan_aim(input)
    horizontal = 0
    depth = 0
    aim = 0

    for row in input
        direction, amount = split(row, ' ')
        amount = parse(Int64, amount)
        if direction == "forward"
            horizontal += amount
            depth += amount*aim
        elseif direction == "up"
            aim -= amount
        elseif direction == "down"
            aim += amount
        end
    end

    return horizontal*depth
end

function test_plan()
    input = ["forward 5", "down 5", "forward 8", "up 3", "down 8", "forward 2"]
    @assert plan_course(input) == 150
    @assert plan_aim(input) == 900
end

test_plan()

include("../get_input.jl")

input = read_input()
dist_prod = plan_course(input)
println("Product of distances: ", dist_prod)
aim_prod = plan_aim(input)
println("Product of distances (aim): ", aim_prod)
