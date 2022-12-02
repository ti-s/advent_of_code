
abstract type Shape end
struct Rock <: Shape end
struct Paper <: Shape end
struct Scissor <: Shape end

score(::Rock) = 1
score(::Paper) = 2
score(::Scissor) = 3

score(other::T, own::T) where {T<:Shape} = 3
score(other::Rock, own::Paper) = 6
score(other::Rock, own::Scissor) = 0
score(other::Paper, own::Scissor) = 6
score(other::Shape, own::Shape) = 6 - score(own, other)

total_score(other::Shape, own::Shape) = score(other, own) + score(own)

function Shape(s::Symbol)
    if s in [:A, :X]
        return Rock()
    elseif s in [:B, :Y]
        return Paper()
    elseif s in [:C, :Z]
        return Scissor()
    else
        throw(DomainError("Invalid shape symbol: $s"))
    end
end


function parse_line(line)
    return Shape.(Symbol.(split(line)))
end

function parse_input(stream)
    return [parse_line(line) for line in eachline(stream)]
end

function play(games)
    sum(total_score(game...) for game in games)
end

games = parse_input("$(dirname(@__FILE__))/input.txt")
println("Total score: $(play(games))")