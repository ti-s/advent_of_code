const Pos = CartesianIndex{2}

function load_array(lines)
    width = length(first(lines))
    height = length(lines)
    heights = Matrix{Char}(undef, height, width)
    S = Pos(0, 0)
    E = Pos(0, 0)
    for i = 1:height, j = 1:width
        c = lines[i][j]
        if c == 'S'
            S = Pos(i, j)
            heights[i, j] = 'a'
        elseif c == 'E'
            E = Pos(i, j)
            heights[i, j] = 'z'
        else
            heights[i, j] = c
        end
    end
    heights, S, E
end

max_len(heights) = length(heights)


function find_path(paths, pos, len, heights, goal; up=true)
    if goal(pos, heights[pos])
        # found path
        return len
    elseif paths[pos] <= len
        # already visited
        return max_len(heights)
    end
    paths[pos] = len
    min_len = max_len(heights)
    for dir in [Pos(0, 1), Pos(0, -1), Pos(1, 0), Pos(-1, 0)]
        next = pos + dir
        checkbounds(Bool, heights, next) || continue
        if up
            heights[next] > heights[pos] + 1 && continue
        else
            heights[pos] > heights[next] + 1 && continue
        end
        path_len = find_path(paths, next, len + 1, heights, goal; up=up)
        if path_len < min_len
            min_len = path_len
        end
    end
    return min_len
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    heights, S, E = load_array(readlines(testfilename))
    paths = fill(max_len(heights), size(heights)...)

    path_len = find_path(paths, S, 0, heights, (p, h) -> p == E)
    test = path_len

    heights, S, E = load_array(readlines(filename))
    paths = fill(max_len(heights), size(heights)...)

    path_len = find_path(paths, S, 0, heights, (p, h) -> p == E)
    part1 = path_len

    paths = fill(max_len(heights), size(heights)...)
    path_len = find_path(paths, E, 0, heights, (p, h) -> h == 'a', up=false)
    part2 = path_len

    println("Test: ", test)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
