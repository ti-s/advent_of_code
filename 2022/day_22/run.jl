using LinearAlgebra
using OffsetArrays

const Pos = CartesianIndex{2}

const Pos3 = CartesianIndex{3}

function parse_grid(stream)
    lines = collect(stream)
    rows = length(lines)
    cols = maximum(length, lines)
    grid = fill(' ', rows, cols)
    for (i, line) in enumerate(lines)
        for j in eachindex(line)
            grid[i, j] = line[j]
        end
    end
    grid
end

function parse_instructions(stream)
    line = first(stream)
    parts = [line[I] for I in findall(r"\d+|[LR]", line)]
    [all(isdigit, elem) ? parse(Int, elem) : elem for elem in parts]
end

function parse_input(stream)
    grid = parse_grid(Iterators.takewhile(!isempty, stream))
    instructions = parse_instructions(stream)
    grid, instructions
end


function get_ranges(grid, dim)
    [findfirst(!=(' '), chars):findlast(!=(' '), chars) for chars in eachslice(grid, dims=dim)]
end

function get_ranges(grid)
    row_ranges = get_ranges(grid, 1)  # valid indices for each row
    col_ranges = get_ranges(grid, 2)  # valid indices for each column
    row_ranges, col_ranges

end


function rotate2d(direction, instruction)
    new_dir = Pos(direction[2], -direction[1])
    if instruction == "R"
        return new_dir
    else
        return -new_dir
    end
end

function move2d(grid, row_ranges, col_ranges, pos, direction, instruction::Int)
    for i in 1:instruction
        new_pos = pos + direction
        row, col = Tuple(new_pos)
        if direction[1] == 0
            # moving within the same row
            valid_row = row
            valid_col = mod(col, row_ranges[row])
        else
            # moving within the same column
            valid_row = mod(row, col_ranges[col])
            valid_col = col
        end
        new_pos = Pos(valid_row, valid_col)
        if grid[new_pos] == '#'
            break
        end
        pos = new_pos
        @assert grid[pos] == '.'
    end
    return pos, direction
end

function move2d(grid, row_ranges, col_ranges, pos, direction, instruction::String)
    pos, rotate2d(direction, instruction)
end

function follow_instructions2d(grid, instructions)
    row_ranges, col_ranges = get_ranges(grid)
    pos = Pos(1, first(row_ranges[1]))
    direction = Pos(0, 1)
    for instr in instructions
        pos, direction = move2d(grid, row_ranges, col_ranges, pos, direction, instr)
    end
    pos, direction
end


function move3d(faces, pos3, dir3, face)
    # The position on the cube is given by the face and the position pos on the face
    # By moving one step in direction dir3, either the position on the face
    # or the face and direction changes
    next_pos3 = pos3 + dir3
    next_face = face
    next_dir3 = dir3
    if !checkbounds(Bool, faces[face], next_pos3)
        next_face = dir3
        next_dir3 = -face
        next_pos3 = pos3
    end
    next_pos3, next_dir3, next_face
end

function rotate3d(direction, face, instruction)
    # The cross product a×b turns b around a by 90° counterclockwise
    new_dir = cross([Tuple(face)...], [Tuple(direction)...])
    if instruction == "L"
        # Turn 90° counterclockwise around the face vector
        return Pos3(new_dir...)
    else
        # Turn 90° clockwise around the face vector
        return -Pos3(new_dir...)
    end
end


function create_cube_faces(grid, len)
    # Represent the cube by its 6 faces
    # The key is the vector orthogonal to the face
    # The faces store the corresponding positions on the 2d grid
    # The coordinate system is x, y, z with x -> right, y -> behind, and z -> up
    faces = Dict{Pos3,OffsetArray{Pos,3}}()
    faces[Pos3(1, 0, 0)] = OffsetArray{Pos}(undef, len:len, 1:len, 1:len)
    faces[Pos3(-1, 0, 0)] = OffsetArray{Pos}(undef, 1:1, 1:len, 1:len)
    faces[Pos3(0, 1, 0)] = OffsetArray{Pos}(undef, 1:len, len:len, 1:len)
    faces[Pos3(0, -1, 0)] = OffsetArray{Pos}(undef, 1:len, 1:1, 1:len)
    faces[Pos3(0, 0, 1)] = OffsetArray{Pos}(undef, 1:len, 1:len, len:len)
    faces[Pos3(0, 0, -1)] = OffsetArray{Pos}(undef, 1:len, 1:len, 1:1)
    for (_, face) in faces
        fill!(face, Pos(0, 0))
    end
    # First valid position is the start position
    start_pos = Pos(1, findfirst(!=(' '), grid[1, :]))
    start_dir = Pos(0, 1)
    # Place this position on the top face of the cube
    start_face = Pos3(0, 0, 1)
    start_pos3 = Pos3(1, 1, len)
    start_dir3 = Pos3(0, 1, 0)
    fill_cube_faces!(faces, grid, start_pos, start_dir, start_face, start_pos3, start_dir3)
    faces, start_pos3, start_dir3, start_face
end

function fill_cube_faces!(faces, grid, pos, dir, face, pos3, dir3)
    # DFS over all valid positions in the grid
    # For each step on the grid in the current direction on the grid,
    # make one step on the cube in the current direction on the cube
    # For each turn of the direction on the grid, make the same turn on the cube
    if faces[face][pos3] != Pos(0, 0)
        @assert faces[face][pos3] == pos
        return
    else
        faces[face][pos3] = pos
    end
    # For each direction, make a step in that direction and recurse from there
    for _ = 1:4
        next_pos = pos + dir
        if !checkbounds(Bool, grid, next_pos) || grid[next_pos] == ' '
            # We cannot go in the current direction on the grid
            @goto rotate
        end
        next_pos3, next_dir3, next_face = move3d(faces, pos3, dir3, face)
        fill_cube_faces!(faces, grid, next_pos, dir, next_face, next_pos3, next_dir3)
        @label rotate
        dir = rotate2d(dir, "R")
        dir3 = rotate3d(dir3, face, "R")
    end
end


function move3d(grid, faces, pos3, dir3, face, instr::Int)
    for _ = 1:instr
        next_pos3, next_dir3, next_face = move3d(faces, pos3, dir3, face)
        if grid[faces[next_face][next_pos3]] == '#'
            break
        end
        pos3 = next_pos3
        dir3 = next_dir3
        face = next_face
        @assert grid[faces[face][pos3]] == '.'
    end
    pos3, dir3, face
end

function move3d(grid, faces, pos3, dir3, face, instr::String)
    pos3, rotate3d(dir3, face, instr), face
end

function map_direction(faces, pos3, dir3, face)
    # one can move either in +dir3 or -dir3 on the cube without changing faces
    # from the corresponding two positions on the map, one can calculate the
    # direction on the map
    pos = faces[face][pos3]
    next_pos3, next_dir3, next_face = move3d(faces, pos3, dir3, face)
    if face == next_face
        next_pos = faces[next_face][next_pos3]
        return next_pos - pos
    else
        next_pos3, next_dir3, next_face = move3d(faces, pos3, -dir3, face)
        @assert face == next_face
        next_pos = faces[next_face][next_pos3]
        return pos - next_pos
    end
end

function follow_instructions3d(grid, instructions)
    len = Int(sum(size(grid)) / 7)
    faces, pos3, dir3, face = create_cube_faces(grid, len)
    for instr in instructions
        pos3, dir3, face = move3d(grid, faces, pos3, dir3, face, instr)
    end
    pos = faces[face][pos3]
    direction = map_direction(faces, pos3, dir3, face)
    pos, direction
end


face_value(direction) = findfirst(==(direction), [Pos(0, 1), Pos(1, 0), Pos(0, -1), Pos(-1, 0)]) - 1

function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    grid, instructions = parse_input(eachline(testfilename))
    pos, direction = follow_instructions2d(grid, instructions)
    test1 = 1000 * pos[1] + 4 * pos[2] + face_value(direction)

    pos, direction = follow_instructions3d(grid, instructions)
    test2 = 1000 * pos[1] + 4 * pos[2] + face_value(direction)

    grid, instructions = parse_input(eachline(filename))
    pos, direction = follow_instructions2d(grid, instructions)
    part1 = 1000 * pos[1] + 4 * pos[2] + face_value(direction)

    pos, direction = follow_instructions3d(grid, instructions)
    part2 = 1000 * pos[1] + 4 * pos[2] + face_value(direction)

    println("Test 1: ", test1)
    println("Test 2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
