import SparseArrays
include("../get_input.jl")

function preprocess_input(input)
    numbers = parse.(Int, reduce(vcat, split.(reduce(vcat, split.(input, " -> ")), ",")))
    num_lines = Int(length(numbers) / 4)
    xyxy = reshape(numbers, (4, num_lines))'
    return xyxy
end

function store_lines(lines, hv=true)
    max_x = 0
    max_y = 0
    for i in range(1, size(lines, 1))
        x1, y1, x2, y2 = lines[i, :]
        max_x = max(max_x, max(x1, x2))
        max_y = max(max_y, max(y1, y2))
    end

    line_sums = spzeros(max_x + 1, max_y + 1)
    for i in range(1, size(lines, 1))
        x1, y1, x2, y2 = lines[i, :]
        if hv && (x1 != x2) && (y1 != y2)
            continue
        end

        x_slope, y_slope = x2 - x1, y2 - y1
        x_inc, y_inc = 0, 0
        if y_slope != 0
            y_inc = sign(y_slope)
        end
        if x_slope != 0
            x_inc = sign(x_slope)
        end

        num_steps = max(abs(x_slope), abs(y_slope))
        x, y = x1, y1
        for _ in range(1, num_steps+1)
            line_sums[x+1, y+1] += 1
            # println("    x, y: ", x, ",",y, " ", line_sums[x+1, y+1])
            x += x_inc
            y += y_inc
        end
        
    end
    return line_sums

end

function test()
    input = read_input("test.txt")
    xyxy = preprocess_input(input)
    line_matrix = store_lines(xyxy)
    # println(sum(line_matrix .> 1))
    @assert sum(line_matrix .> 1) == 5
    line_matrix = store_lines(xyxy, false)
    # println(sum(line_matrix .> 1))
    @assert sum(line_matrix .> 1) == 12
end

test()

input = read_input()
xyxy = preprocess_input(input)
line_matrix = store_lines(xyxy)
println("Thermal vents: ", sum(line_matrix .> 1))
line_matrix = store_lines(xyxy, false)
println("Thermal vents: ", sum(line_matrix .> 1))
