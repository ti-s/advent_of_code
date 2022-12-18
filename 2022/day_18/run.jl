using OffsetArrays

const Pos = CartesianIndex{3}

parse_pos(line) = Pos(parse.(Int, split(line, ","))...)
load_input(stream) = parse_pos.(stream)
get_extrema(positions) = extrema(reinterpret(reshape, Int, positions), dims=2)

function create_array(positions)
    # add padding
    axes = [i-1:j+1 for (i, j) in get_extrema(positions)]
    array = OffsetArray{Char}(undef, axes...)
    array .= '.'
    for pos in positions
        array[pos] = '#'
    end
    array
end

directions = [
    Pos(-1, 0, 0),
    Pos(1, 0, 0),
    Pos(0, -1, 0),
    Pos(0, 1, 0),
    Pos(0, 0, -1),
    Pos(0, 0, 1)
]

function count_faces(f, array, positions)
    count = 0
    for pos in positions
        for d in directions
            count += f(array[pos+d])
        end
    end
    count
end

function fill_water!(array, pos)
    checkbounds(Bool, array, pos) || return
    if array[pos] == '.'
        array[pos] = '~'
    else
        return
    end
    for d in directions
        fill_water!(array, pos + d)
    end
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    positions = load_input(eachline(testfilename))
    grid = create_array(positions)
    test1 = count_faces(==('.'), grid, positions)
    fill_water!(grid, Pos(0, 0, 0))
    test2 = count_faces(==('~'), grid, positions)

    positions = load_input(eachline(filename))
    grid = create_array(positions)
    part1 = count_faces(==('.'), grid, positions)
    fill_water!(grid, Pos(0, 0, 0))
    part2 = count_faces(==('~'), grid, positions)

    println("Test 1: ", test1)
    println("Test 2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
