include("../get_input.jl")
using DataStructures

SCORE_TABLE = Dict(')'=> 3, ']'=> 57, '}'=> 1197, '>'=> 25137)
COMPLEMENTS = Dict(')'=> '(', ']'=> '[', '}'=> '{', '>'=> '<')
AUTO_SCORE_TABLE = Dict('(' => 1, '[' => 2, '{' => 3,'<' => 4)

function evaluate_line(line)
    # Return 0 if the line is correct
    # Return -1 if the line is incomplete
    # Else, return i in [1, N], where i corresponds
    # to the index of the first invalid character

    char_counts = Dict('['=>0, '{'=>0,'('=>0, '<'=>0)
    parens = DataStructures.Stack{Char}()

    char_index = 1
    for c_char in line

        # Keep a record of counts
        if haskey(char_counts, c_char)
            char_counts[c_char] += 1
            push!(parens, c_char)
        elseif haskey(COMPLEMENTS, c_char)
            opener = COMPLEMENTS[c_char]

            if first(parens) == opener
                pop!(parens)
                char_counts[opener] -= 1
            else
                return char_index
            end

            # println(c_char)
        else
            error("Unknown character encountered: ", c_char)
        end
        char_index += 1
    end

    # println(sum(values(char_counts)))
    # for (key, value) in pairs(char_counts)
    #     println(key, " => ", value)
    # end
    if sum(values(char_counts)) == 0
        return 0
    end
    return -1
end

function compute_syntax_error_score(text)
    ses = 0
    for line in text
        res = evaluate_line(line)
        if res >= 1
            invalid_char = line[res]
            # println("FOUND INVALID CHAR: ", invalid_char)
            ses += SCORE_TABLE[invalid_char]
        end
    end
    return ses
end

function autocomplete_line(line)

    char_counts = Dict('['=>0, '{'=>0,'('=>0, '<'=>0)
    parens = DataStructures.Stack{Char}()
    autocomplete_score = 0

    for c_char in line

        # Keep a record of counts
        if haskey(char_counts, c_char)
            push!(parens, c_char)
        elseif haskey(COMPLEMENTS, c_char)
            opener = COMPLEMENTS[c_char]

            if first(parens) == opener
                pop!(parens)
            end
        end
    end

    while ! isempty(parens)
        c_char = pop!(parens)
        autocomplete_score = autocomplete_score * 5 + AUTO_SCORE_TABLE[c_char]
    end

    return autocomplete_score
end

function compute_autocomplete_score(text)
    scores = []
    for line in text
        res = evaluate_line(line)
        if res < 0
            append!(scores, autocomplete_line(line))
        end
    end

    sort!(scores)
    midpoint = Int((length(scores) + 1) / 2)
    return scores[midpoint]
end

function test()
    input = read_input("test.txt")
    total_ses = compute_syntax_error_score(input)

    @assert total_ses == 26397

    acs = compute_autocomplete_score(input)
    @assert acs == 288957
end

test()

input = read_input()
total_ses = compute_syntax_error_score(input)
println("SES: ", total_ses)
acs = compute_autocomplete_score(input)
println("ACS: ", acs)
