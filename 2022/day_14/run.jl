const Pos = CartesianIndex{2}

parse_coords(str) = Pos(reverse(parse.(Int, split(str, ",")))...)
parse_line(line) = parse_coords.(split(line, " -> "))
parse_lines(lines) = [parse_line(line) for line in lines]

extrem_coords(line::Vector{Pos}, axis) = extrema(getindex.(Tuple.(line), axis))
extrem_coords(lines, axis) = extrema(reinterpret(Int, (extrem_coords.(lines, axis))))

function create_cave(lines, start, bottom=false)
    min_height, max_height = extrem_coords(lines, 1)
    min_height < 0 && error("Height must be positive")

    # add floor
    height = max_height + 2 + 1
    min_width, max_width = extrem_coords(lines, 2)
    # sand builds a triangle
    min_width = min(min_width, start[2] - height)
    max_width = max(max_width, start[2] + height)
    width = max_width - min_width
    # shift everything so that it fits into width
    shift = Pos(1, 1 - min_width)
    shifted_start = start + shift

    cave = fill('.', height, width)
    for line in lines
        start, state = iterate(line)
        for stop in Iterators.rest(line, state)
            h1, w1 = Tuple(start + shift)
            h2, w2 = Tuple(stop + shift)
            cave[min(h1, h2):max(h1, h2), min(w1, w2):max(w1, w2)] .= '#'
            start = stop
        end
    end
    if bottom
        cave[height, :] .= '#'
    end
    cave[shifted_start] = '+'
    cave, shifted_start
end

print_cave(cave) = (foreach(println ∘ String, eachrow(cave)); println())

function move_one_step!(cave, current)
    for dir in [Pos(1, 0), Pos(1, -1), Pos(1, 1)]
        next = current + dir
        cave[next] == '.' && return next
    end
    cave[current] = 'o'
    return nothing
end

function come_to_rest!(cave, start)
    pos = move_one_step!(cave, start)
    try
        while !isnothing(pos)
            pos = move_one_step!(cave, pos)
        end
    catch e
        e isa BoundsError && return false
    end
    return true
end

function simulate_sand!(cave, start)
    count = 0
    while come_to_rest!(cave, start)
        count += 1
        cave[start] == 'o' && break
    end
    count
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    start = Pos(0, 500)

    lines = parse_lines(eachline(testfilename))
    cave, shifted_start = create_cave(lines, start)
    test1 = simulate_sand!(cave, shifted_start)
    print_cave(cave)

    cave, shifted_start = create_cave(lines, start, true)
    test2 = simulate_sand!(cave, shifted_start)
    print_cave(cave)

    lines = parse_lines(eachline(filename))
    cave, shifted_start = create_cave(lines, start)
    part1 = simulate_sand!(cave, shifted_start)
    print_cave(cave)

    cave, shifted_start = create_cave(lines, start, true)
    part2 = simulate_sand!(cave, shifted_start)
    print_cave(cave)

    println("Test 1: ", test1)
    println("Test 1: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
