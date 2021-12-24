include("../get_input.jl")

function preprocess_input(input)
    numbers = parse.(Int, split(input[1], ","))
    boards = input[2:end]
    filter!(x -> x != "", boards)

    boards = reduce(vcat, parse.(Int, row) for row in split.(boards))
    n_boards = Int(length(boards) / 5 / 5)
    boards = permutedims(reshape(boards, 5, 5, n_boards), (2, 1, 3))
    return numbers, boards
end

function play_bingo(numbers, boards)
    marked = zeros(Bool, size(boards))
    M, N = size(boards)[1:2]
    for number in numbers
        # println("Number: ", number)
        marked = marked .| (boards .== number)

        row_sums = sum(marked; dims=2)
        row_wins = findall(row_sums .== N)
        col_sums = sum(marked; dims=1)
        col_wins = findall(col_sums .== M)
        board = 0
        if length(row_wins) > 0
            # println("ROW WIN:")
            # println("Num wins:", length(row_wins))
            board = row_wins[1][3]
        elseif length(col_wins) > 0
            # println("COL WIN:")
            # println("num wins: ", length(col_wins))
            board = col_wins[1][3]
        end

        if board != 0
            # println(board)
            board_marked = marked[:, :, board]
            unmarked_sum = sum(boards[:, :, board][.!board_marked])
            return unmarked_sum * number
        end
    end
    return 0
end

function lose_bingo(numbers, boards)
    marked = zeros(Bool, size(boards))
    M, N, B = size(boards)
    winning_boards = Set()
    for number in numbers
        # println("Number: ", number)
        marked = marked .| (boards .== number)

        row_sums = sum(marked; dims=2)
        row_wins = findall(row_sums .== N)
        col_sums = sum(marked; dims=1)
        col_wins = findall(col_sums .== M)
        board = 0
        this_round = Set()
        for index in row_wins
            board = index[3]
            if !in(board, winning_boards)
                push!(this_round, board)
            end
            push!(winning_boards, board)
        end
        for index in col_wins
            board = index[3]
            if !in(board, winning_boards)
                push!(this_round, board)
            end
            push!(winning_boards, board)
        end

        # println("Winning Boards: ", length(winning_boards))
        # println("Won this round: ", length(this_round), " ", this_round)

        if length(winning_boards) == B
            board = first(this_round)
            board_marked = marked[:, :, board]
            unmarked_sum = sum(boards[:, :, board][.!board_marked])
            return unmarked_sum * number
        end

        
    end
    return 0
end

function test()
    input = read_input("test.txt")
    numbers, boards = preprocess_input(input)
    score = play_bingo(numbers, boards)
    @assert score == 4512
end

test()

input = read_input()
numbers, boards = preprocess_input(input)

score = play_bingo(numbers, boards)
println("BINGO SCORE: ", score)
score = lose_bingo(numbers, boards)
println("BINGO SCORE: ", score)
