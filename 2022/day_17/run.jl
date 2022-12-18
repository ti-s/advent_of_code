include(joinpath(@__DIR__, "../../MagicArrays.jl"))

function parse_shape(s)
    lines = strip.(split(strip(s), "\n"))
    N = length(lines)
    M = length(lines[1])
    [lines[i][j] for i = N:-1:1, j = 1:M]
end

function shapes()
    strings = [
        """
            ####
        """,
        """
            .#.
            ###
            .#.
        """,
        """
            ..#
            ..#
            ###
        """,
        """
            #
            #
            #
            #
        """,
        """
            ##
            ##
        """
    ]
    [parse_shape(s) for s in strings]
end

function load_input(filename)
    strip(read(filename, String))
end

function new_cave()
    cave = MagicMatrix('.')
    cave[0:0, 1:7] .= '-'
    cave
end

print_cave(cave) = (foreach(println ∘ String, Iterators.reverse(eachrow(cave))); println())

function print_caves(c1, c2)
    h = min(size(c1, 1), size(c2, 1))
    for i in h:-1:1
        println(String(c1[i, :]), "   ", String(c2[i, :]))
    end
end


function hasoverlap(cave, s, row, col)
    rows, cols = axes(s)
    any(cave[rows.+row.-1, cols.+col.-1] .== s .== '#')
end


function place!(cave, s, row, col)
    rows, cols = axes(s)
    coords = rows .+ row .- 1, cols .+ col .- 1
    mask = cave[coords...] .== '.'
    @views cave[coords...][mask] .= s[mask]
    cave
end


function fall!(cave, shapes, input, rounds)
    _fall!(
        cave,
        Iterators.Stateful(Iterators.cycle(shapes)),
        Iterators.Stateful(Iterators.cycle(input)),
        rounds
    )
end

dir(s) = ifelse(s == '<', -1, 1)

function _fall!(cave, shapes, input, rounds)
    heights = Int[]
    for _ = 1:rounds
        s = first(shapes)
        row, col = size(cave, 1) + 3, 3
        # print_cave(place!(deepcopy(cave), s, row, col))
        while true
            si = first(input)
            # @show s, si
            d = dir(si)
            new_col = col + d
            new_col = clamp(new_col, 1:size(cave, 2)-size(s, 2)+1)
            # @show row, col
            if hasoverlap(cave, s, row, new_col)
                col = col
            else
                col = new_col
            end
            # @show row, col
            # print_cave(place!(deepcopy(cave), s, row, col))
            if row - 1 < 1 || hasoverlap(cave, s, row - 1, col)
                place!(cave, s, row, col)
                break
            end
            row -= 1
            # print_cave(place!(deepcopy(cave), s, row, col))
        end
        push!(heights, size(cave, 1) - 1)
    end
    heights
end

function detect_cycle_from_start(array)
    len = 1
    # there should be at least one full repetitions
    max_len = size(array, 1) ÷ 2
    while len <= max_len
        new_len = 0
        for i in len+1:size(array, 1)
            if array[((i-1)%len)+1, :] != array[i, :]
                new_len = i - 1
                break
            end
        end
        if new_len == 0
            return len
        else
            len = max(len + 1, new_len)
        end
    end
    return 0
end

function detect_cycle(array)
    for start = 1:size(array, 1)÷3
        len = detect_cycle_from_start(@view array[start:end, :])
        if len > 0
            return start, len
        end
    end
    0, 0
end

function fall_until_cycle!(cave, shapes, input, rounds)
    shapes = Iterators.Stateful(Iterators.cycle(shapes))
    input = Iterators.Stateful(Iterators.cycle(input))
    heights = Int[]

    while length(heights) < 100000
        heights = [heights; _fall!(cave, shapes, input, rounds)]
        start, len = detect_cycle(diff(heights))
        if start > 0 && len > 0
            return start, len, heights
        end
        rounds = 2 * rounds
    end
    0, 0, heights
end

function get_height(start, len, heights, rounds)
    height_gain_per_cycle = sum(diff(heights[start:start+len-1]))
    reduced_rounds = (rounds - start) % len + start
    heights[reduced_rounds] + (rounds - start) ÷ len * height_gain_per_cycle
end

function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    input = load_input(testfilename)
    cave = new_cave()
    start, len, heights = fall_until_cycle!(cave, shapes(), input, 100)
    print_cave(cave)
    test1 = get_height(start, len, heights, 2022)
    test2 = get_height(start, len, heights, 1000000000000)
    println("Test 1: ", test1)
    println("Test 2: ", test2)

    input = load_input(filename)
    cave = new_cave()
    start, len, heights = fall_until_cycle!(cave, shapes(), input, 100)
    part1 = get_height(start, len, heights, 2022)
    part2 = get_height(start, len, heights, 1000000000000)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
