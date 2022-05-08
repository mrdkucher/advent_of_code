include("../get_input.jl")
using DataStructures

function preprocess_input(input)
    numbers = parse.(Int, split(input, ","))
    return numbers
end

struct SevenSegment
    top::Char
    top_left::Char
    top_right::Char
    middle::Char
    bottom_left::Char
    bottom_right::Char
    bottom::Char
end

#  Number: SEGMENTS
#  1         2 *      
#  2         5  1     
#  3         5  2     
#  4         4 *     
#  5         5  3     
#  6         6   1    
#  7         3 *      
#  8         7 *      
#  9         6   2    
#  0         6   3    

# MAPPING
# 0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....

#   5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
#  gggg    gggg    ....    gggg    gggg

# 1: len 2
# 2: 5 segment number -> if SI w/ 1 is len 1 and SI w/ 4 is len 2, then we know it is a 2!
# 3: 5 segment number -> if SI w/ 1 is len 2, then we know it is a 3!
# 4: len 4
# 5: 5 segment number -> if SI w/ 1 is len 1 and SI w/ 4 is len 3, then we know it is a 5!
# 6: 6 segment number -> if SI w/ 1 is len 1, then we know it is a 6!
# 7: len 3
# 8: len 7
# 9: 6 segment number -> if SI w/ 4 is len 4, then we know it is a 9!
# 0: 6 segment number -> if SI w/ 1 is len 2 and SI w/ 4 is len 3, then we know it is a 0!


# Set intersection between 7 and 2, then set minus with TOP letter gives us Top top_right

number_to_segments = Dict(
    1 => 2, 2 => 5, 3 => 5, 4 => 4, 5 => 5, 
    6 => 6, 7 => 3, 8 => 7, 9 => 6, 0 => 6
)

function count_message_matches(number_encodings, number)
    target_segments = number_to_segments[number]
    count = 0
    letters = ""
    for encoding in number_encodings
        if length(encoding) == target_segments
            letters = encoding
            count += 1
        end
    end
    return count, letters
end

function count_easy(line)
    display = last(split(line, "| "))
    number_encodings = split(display, " ")
    count = count_message_matches(number_encodings, 1)[1]
    count += count_message_matches(number_encodings, 4)[1]
    count += count_message_matches(number_encodings, 7)[1]
    count += count_message_matches(number_encodings, 8)[1]
    return count
end

function decode_display(line)
    mapping, display = split(line, " | ")
    map_encodings = split(mapping, " ")
    _, let_1 = count_message_matches(map_encodings, 1)
    _, let_4 = count_message_matches(map_encodings, 4)
    _, let_7 = count_message_matches(map_encodings, 7)
    _, let_8 = count_message_matches(map_encodings, 8)
    let_1, let_4, let_7, let_8 = Set(let_1), Set(let_4), Set(let_7), Set(let_8)

    number_encodings = split(display, " ")
    line_sum = 0
    for (i, encoding) in enumerate(number_encodings)
        if length(encoding) == 2
            value = 1
        elseif length(encoding) == 3
            value = 7
        elseif length(encoding) == 4
            value = 4
        elseif length(encoding) == 5
            if length(intersect(Set(encoding), let_1)) == 2
                value = 3
            elseif length(intersect(Set(encoding), let_4)) == 3
                value = 5
            else
                value = 2
            end
        elseif length(encoding) == 6
            if length(intersect(Set(encoding), let_1)) == 1
                value = 6
            elseif length(intersect(Set(encoding), let_4)) == 4
                value = 9
            else
                value = 0
            end
        elseif length(encoding) == 7
            value = 8
        else
            error("Encoding has inproper length")
        end
        line_sum += value * 10 ^(4 - i)
    end
    return line_sum
end

function test()
    input = read_input("test.txt")
    count = 0
    for line in input
        count += count_easy(line)
    end
    @assert count == 26
    total_sum = 0
    for line in input
        line_value = decode_display(line)
        total_sum += line_value
    end
    @assert total_sum == 61229
end

test()

input = read_input()
total_easy = 0
for line in input
    global total_easy
    total_easy += count_easy(line)
end
println("count: ", total_easy)
total_sum = 0
for line in input
    global total_sum
    line_value = decode_display(line)
    total_sum += line_value
end
println("sum: ", total_sum)
