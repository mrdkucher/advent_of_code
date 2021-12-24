function split_input(input)
    bounds, letter, password = split(input, ' ')
    letter = first(strip(letter, ':'))
    lower, upper = map(x->parse(Int64, x), split(bounds, '-'))
    return lower, upper, letter, password
end

function validate_password(input)
    lower, upper, letter, password = split_input(input)

    count = 0
    for ch in password
        if ch == letter
            count += 1
        end
    end
    return (lower <= count) && (count <= upper)
end

function test_validate_password()
    @assert validate_password("1-3 a: abcde")
    @assert !validate_password("1-3 b: cdefg")
    @assert validate_password("2-9 c: ccccccccc")

    inputs = ["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"]
    @assert sum(map(validate_password, inputs)) == 2
end

function validate_password_position(input)
    first, second, letter, password = split_input(input)

    return xor(password[first] == letter, password[second] == letter)
end

function test_validate_password_position()
    @assert validate_password_position("1-3 a: abcde")
    @assert !validate_password_position("1-3 b: cdefg")
    @assert !validate_password_position("2-9 c: ccccccccc")

    inputs = ["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"]
    @assert sum(map(validate_password_position, inputs)) == 1
end

test_validate_password()
test_validate_password_position()

include("../get_input.jl")

lines = read_input()
num_valid_passwords = sum(map(validate_password, lines))
println("Num valid passwords: ", num_valid_passwords)
num_valid_passwords = sum(map(validate_password_position, lines))
println("Num valid passwords 2: ", num_valid_passwords)
