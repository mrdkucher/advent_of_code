include("../get_input.jl")
using DataStructures

function flood_filler(matrix, pq)
    
end

function find_basins(height_map, matrix, low_point_locations)
    pq = PriorityQueue{CartesianIndex{2}, Int}(Base.Order.Reverse)
    visited = zeros(Bool, size(matrix))
    basin_map = zeros(Int, size(matrix))
    next_up = Queue{Tuple{Int, Int}}()
    
    # disallow 9s from basins
    matrix[height_map .== 9] .= 100

    R, C = size(matrix)
    basin_counter = 1
    for lp in low_point_locations
        enqueue!(next_up, Tuple(lp))

        basin_size = 0
        while ~isempty(next_up)
            row, col = dequeue!(next_up)

            if ~visited[row, col] && matrix[row, col] < 100
                if row + 1 <= R && ~visited[row + 1, col]
                    enqueue!(next_up, (row + 1, col))
                end

                if row - 1 > 0 && ~visited[row - 1, col]
                    enqueue!(next_up, (row - 1, col))
                end

                if col + 1 <= C && ~visited[row, col + 1]
                    enqueue!(next_up, (row, col + 1))
                end

                if col - 1 > 0 && ~visited[row, col - 1]
                    enqueue!(next_up, (row, col - 1))
                end
                
                basin_size += 1
                basin_map[row, col] = basin_counter
            end

            visited[row, col] = true
        end
        basin_counter += 1
        enqueue!(pq, lp, basin_size)
    end
    
    total_size = 1
    for _ in range(1, 3)
        location, basin_size  = dequeue_pair!(pq)
        total_size *= basin_size
    end

    return total_size
end

function lowest_points(matrix)
    row_derivative = sign.(circshift(circshift(matrix, 1) - matrix, -1)) + sign.(circshift(circshift(matrix, -1) - matrix, 1))
    col_derivative = transpose(sign.(circshift(circshift(transpose(matrix), 1) - transpose(matrix), -1)) + sign.(circshift(circshift(transpose(matrix), -1) - transpose(matrix), 1)))

    low_points = row_derivative + col_derivative
    lowest_heights = matrix[low_points .== -4]
    risks = lowest_heights .+ 1

    basins = low_points[2:end-1, 2:end-1]
    locations = findall(basins .== -4)
    basin_size = find_basins(matrix[2:end-1, 2:end-1], sign.(basins), locations)

    return sum(risks), basin_size
end

function create_matrix(input)
    height_map = zeros(Int, length(input) + 2, length(input[1]) + 2) .+ 10
    row, col = 2, 2

    for line in input
        for char in line
            height_map[row, col] = parse(Int, char)
            col += 1
        end
        col = 2
        row += 1
    end
    return height_map
end

function test()
    input = read_input("test.txt")
    height_map = create_matrix(input)
    risk, basin_size = lowest_points(height_map)

    @assert risk == 15
    @assert basin_size == 1134

end

test()

input = read_input()
height_map = create_matrix(input)
risk, basin_size = lowest_points(height_map)
println("SUM OF RISK: ", risk)
println("Basin SIZE: ", basin_size)
