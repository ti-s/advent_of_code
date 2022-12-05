function parse_stacks(lines)
    stacks = Vector{Vector{Char}}()
    for line in lines
        '[' in line || break
        for (i, crate) in enumerate(line[2:4:end])
            if i > length(stacks)
                push!(stacks, Char[])
            end
            if crate != ' '
                pushfirst!(stacks[i], crate)
            end
        end
    end
    return stacks
end

function parse_move(line)
    _, n, _, from, _, to = split(line)
    return parse(Int, n), parse(Int, from), parse(Int, to)
end


function parse_moves(lines)
    [parse_move(line) for line in lines]
end


function parse_file(name)
    lines = eachline(name)
    stacks = parse_stacks(lines)
    # remove empty line
    first(lines)
    moves = parse_moves(lines)
    return stacks, moves
end

function execute_moves_one_by_one!(stacks, moves)
    for (n, from, to) in moves
        for _ in 1:n
            crate = pop!(stacks[from])
            push!(stacks[to], crate)
        end
    end
    stacks
end

execute_moves_one_by_one(stacks, moves) = execute_moves_one_by_one!(deepcopy(stacks), moves)

function execute_moves_at_once!(stacks, moves)
    for (n, from, to) in moves
        crates = [pop!(stacks[from]) for _ in 1:n]
        for crate in Iterators.reverse(crates)
            push!(stacks[to], crate)
        end
    end
    stacks
end

execute_moves_at_once(stacks, moves) = execute_moves_at_once!(deepcopy(stacks), moves)

stacks, moves = parse_file(joinpath(@__DIR__, "input.txt"))

new_stacks = execute_moves_one_by_one(stacks, moves)

println("Part 1: ", String(last.(new_stacks)))

new_stacks = execute_moves_at_once(stacks, moves)

println("Part 2: ", String(last.(new_stacks)))