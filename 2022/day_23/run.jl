include(joinpath(@__DIR__, "../../MagicArrays.jl"))

const Pos = CartesianIndex{2}

function parse_input(stream)
    m = MagicMatrix('.')
    for (i, line) in enumerate(stream)
        m[i, 1:length(line)] .= collect(line)
    end
    m
end

print_array(array) = (foreach(println ∘ String, eachrow(array)); println())

function diffuse!(m, n::Real)
    directions = [
        (Pos(-1, -1), Pos(-1, 0), Pos(-1, 1)),
        (Pos(1, -1), Pos(1, 0), Pos(1, 1)),
        (Pos(-1, -1), Pos(0, -1), Pos(1, -1)),
        (Pos(-1, 1), Pos(0, 1), Pos(1, 1)),
    ]
    for i = 1:n
        diffuse!(m, directions) && return i
        dirs = popfirst!(directions)
        push!(directions, dirs)
    end
    n
end

iself(c) = c == '#'

function hasneighbours(m, I, dirs=Pos(-1, -1):Pos(1, 1))
    for J in dirs
        J == Pos(0, 0) && continue
        iself(m[I+J]) && return true
    end
    return false
end

function get_direction(m, I, directions)
    for dirs in directions
        !hasneighbours(m, I, dirs) && return dirs[2]
    end
    return nothing
end

function diffuse!(m, directions)
    proposed = Dict{Pos,Union{Pos,Nothing}}()
    for I in eachindex(m)
        !iself(m[I]) && continue
        !hasneighbours(m, I) && continue  # elves without neighbours don't move
        d = get_direction(m, I, directions)
        isnothing(d) && continue  # no free direction
        if haskey(proposed, I + d)
            # somebody already propesed to go there
            # cancel that move
            proposed[I+d] = nothing
        else
            proposed[I+d] = I
        end
    end
    isempty(proposed) && return true  # no elf needed to move
    for (to, from) in proposed
        isnothing(from) && continue  # move was cancelled
        m[to] = '#'
        m[from] = '.'
    end
    return false
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")
    m = parse_input(eachline(testfilename))
    print_array(m)
    diffuse!(m, 10)
    print_array(m)
    test1 = count(!iself, m)

    m = parse_input(eachline(testfilename))
    n = diffuse!(m, typemax(Int))
    test2 = n

    m = parse_input(eachline(filename))
    diffuse!(m, 10)
    part1 = count(!iself, m)

    m = parse_input(eachline(filename))
    n = diffuse!(m, typemax(Int))
    part2 = n

    println("Test 1: ", test1)
    println("Test 2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
