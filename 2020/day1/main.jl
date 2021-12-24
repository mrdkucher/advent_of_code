
function find_sum(numbers, target)
    number_set = Set(numbers)

    for number in numbers
        if target - number in number_set
            return number * (target - number)
        end
    end
end


function find_3sum(numbers, target)
    number_set = Set(numbers)
    for i in 1:length(numbers)
        for j in i:length(numbers)
            if target - numbers[i] - numbers[j] in number_set
                return numbers[i]*numbers[j]*(target - numbers[i] - numbers[j])
            end
        end
    end
end

function test_find_sum()
    numbers = [1721, 979, 366, 299, 675, 1456]
    @assert find_sum(numbers, 2020) == 514579
    @assert find_3sum(numbers, 2020) == 241861950
end

test_find_sum()

include("../get_input.jl")

lines = read_input()
numbers = map(x->parse(Int64,x), lines)

product = find_sum(numbers, 2020)
println("Product: ", product)
product3 = find_3sum(numbers, 2020)
println("Product of 3: ", product3)
