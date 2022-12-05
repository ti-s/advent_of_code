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


function execute_moves!(stacks, moves; reverse=false)
    for (n, from, to) in moves
        start = lastindex(stacks[from]) - n + 1
        stop = lastindex(stacks[from])
        crates = splice!(stacks[from], start:stop)
        if reverse
            reverse!(crates)
        end
        append!(stacks[to], crates)
    end
    stacks
end

execute_moves(stacks, moves; kwargs...) = execute_moves!(deepcopy(stacks), moves; kwargs...)

stacks, moves = parse_file(joinpath(@__DIR__, "input.txt"))

new_stacks = execute_moves(stacks, moves, reverse=true)

println("Part 1: ", String(last.(new_stacks)))

new_stacks = execute_moves(stacks, moves, reverse=false)

println("Part 2: ", String(last.(new_stacks)))