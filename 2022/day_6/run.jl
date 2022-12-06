using DataStructures

is_token(v, len) = length(Set(v)) == len

function find_token(filename, len)
    open(filename) do file
        count = 0
        b = CircularBuffer(len)
        while !eof(file)
            count += 1
            push!(b, read(file, Char))
            if is_token(b, len)
                return count
            end
        end
    end
end

filename = joinpath(@__DIR__, "input.txt")

println("Part 1: ", find_token(filename, 4))

println("Part 2: ", find_token(filename, 14))
