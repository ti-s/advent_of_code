@enum Direction U = 1 D L R

function Base.parse(::Type{Direction}, s::AbstractString)
    c = only(s)
    if c == 'U'
        U
    elseif c == 'D'
        D
    elseif c == 'L'
        L
    elseif c == 'R'
        R
    else
        throw(ArgumentError("Not a direction: $c"))
    end
end


function parse_line(line)
    dstr, nstr = split(line)
    d, n = parse(Direction, dstr), parse(Int, nstr)
    Iterators.repeated(d, n)
end

function parse_moves(file)
    [d for line in eachline(file) for d in parse_line(line)]
end


const Pos = CartesianIndex{2}

function vec(d::Direction)
    dirs = (Pos(0, 1), Pos(0, -1), Pos(-1, 0), Pos(1, 0))
    dirs[Int(d)]
end

function vec(head::Pos, tail::Pos)
    dx, dy = Tuple(head - tail)
    Pos(
        (dx + sign(dx) * abs(dy) ÷ 2) ÷ 2,
        (dy + sign(dy) * abs(dx) ÷ 2) ÷ 2
    )
end


const Knots = Vector{Pos}

struct Rope
    knots::Knots
end

Rope(n) = Rope([Pos(1, 1) for i = 1:n])
tail(r::Rope) = last(r.knots)

function move_head!(r::Rope, d::Direction)
    r.knots[1] += vec(d)
    for i = 2:length(r.knots)
        r.knots[i] += vec(r.knots[i-1], r.knots[i])
    end
    r
end


# Recursive version
# const KnotsR{N} = NTuple{N,Pos}

# KnotsR(n) = ntuple(i -> Pos(1, 1), n)

# mutable struct RopeR{N}
#     knots::KnotsR{N}
# end

# RopeR(n::Int) = RopeR(KnotsR(n))

# head(r::RopeR) = first(r.knots)
# tail(r::RopeR) = last(r.knots)

# @inline move(head::Pos, tail::Pos) = tail + vec(head, tail)
# @inline move(head::Pos, back::KnotsR{0}) = (head,)
# @inline move(head::Pos, rest::KnotsR{N}) where {N} =
#     (head, move(move(head, first(rest)), Base.tail(rest))...)

# function move_head!(r::RopeR, d::Direction)
#     r.knots = move(first(r.knots) + vec(d), Base.tail(r.knots))
#     r
# end

function unique_tail_postions!(rope, moves)
    Set(tail(move_head!(rope, m)) for m in moves)
end


function visualize(rope::Rope, unique_tail_positions)
    min_x, max_x = extrema(getindex.(rope.knots, 1))
    min_y, max_y = extrema(getindex.(rope.knots, 2))
    min_x2, max_x2 = extrema(getindex.(unique_tail_positions, 1))
    min_y2, max_y2 = extrema(getindex.(unique_tail_positions, 2))

    lower_left = Pos(min(min_x, min_x2), min(min_y, min_y2))
    upper_right = Pos(max(max_x, max_x2), max(max_y, max_y2))
    shift = Pos(1, 1) - lower_left
    upper_right = upper_right + shift

    out = fill('.', upper_right[1], upper_right[2])
    for pos in unique_tail_positions
        out[pos+shift] = '#'
    end
    for (i, knot) in Iterators.reverse(pairs(rope.knots))
        out[knot+shift] =
            if i == 1
                'H'
            elseif i == length(rope.knots)
                'T'
            else
                string(i)[1]
            end
    end
    println("Rope with $(length(rope.knots)) knots:")
    for i in reverse(axes(out, 1))
        println(" ", String(out[i, :]))
    end
    println()
end

function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    moves = parse_moves(testfilename)

    rope = Rope(2)
    unique_tail_positions = unique_tail_postions!(rope, moves)
    test = length(unique_tail_positions)
    visualize(rope, unique_tail_positions)

    moves = parse_moves(filename)

    rope = Rope(2)
    unique_tail_positions = unique_tail_postions!(rope, moves)
    part1 = length(unique_tail_positions)
    visualize(rope, unique_tail_positions)

    rope = Rope(10)
    unique_tail_positions = unique_tail_postions!(rope, moves)
    part2 = length(unique_tail_positions)
    visualize(rope, unique_tail_positions)

    println("Test: ", test)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
