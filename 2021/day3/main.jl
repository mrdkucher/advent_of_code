function count_bits(input)
    n_bits = length(input[1])
    n_rows = length(input)
    counts = zeros(n_bits)
    for row in input
        for (i, bit) in enumerate(row)
            if bit == '1'
                counts[i] += 1
            end
        end
    end
    
    # Construct output:
    mcb = ""
    lcb = ""
    for count in counts
        if count > n_rows / 2
            mcb = mcb * '1'
            lcb = lcb * '0'
        else
            mcb = mcb * '0'
            lcb = lcb * '1'
        end
    end

    return parse(Int, mcb; base=2) * parse(Int, lcb; base=2)
end

function to_bit_array(input)
    bit_input = zeros(Bool, length(input), length(input[1]))
    for (i, row) in enumerate(input)
        bit_input[i, :] = parse.(Bool, collect(row))
    end
    return bit_input
end

function life_support_rating(bit_input, comp = >=)
    n, n_bits = size(bit_input)

    rating = zeros(Bool, n_bits)
    for bit in range(1, n_bits)
        # println("index: ", bit)
        # println("    n: ", n)
        # println("    1s: ", sum(bit_input[:, bit] .== 1))
        if comp(sum(bit_input[:, bit] .== 1), n / 2)
            # println("    keeping 1s:")
            rating[bit] = 1
            # println("    ", rating[1:bit])
        else
            # println("    keeping 0s:")
            rating[bit] = 0
            # println("    ", rating[1:bit])
        end
        mask = bit_input[:, bit] .== rating[bit]
        bit_input = bit_input[mask, :]
        n = size(bit_input)[1]

        if n == 1
            # println(bit_input)
            rating = join(string.(Int.(bit_input)))
            # println("ANSWER:", parse(Int, rating; base=2))
            return parse(Int, rating; base=2)
        end
    end
    rating = join(string.(Int.(rating)))
    return parse(Int, rating; base=2)
end

function test()
    input = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000", "11001", "00010", "01010"]
    power_consumption = count_bits(input)
    @assert power_consumption == 198

    bit_input = to_bit_array(input)
    # println("OGR")
    ogr = life_support_rating(bit_input)
    # println("CSR")
    csr = life_support_rating(bit_input, <)
    # println("ogr: ", ogr)
    # println("csr: ", csr)
    @assert ogr*csr == 230
end

test()

include("../get_input.jl")

input = read_input()
bit_input = to_bit_array(input)
power_consumption = count_bits(input)
println("Power consumption: ", power_consumption)
ogr = life_support_rating(bit_input)
csr = life_support_rating(bit_input, <)
println("Life support rating: ", ogr*csr)
