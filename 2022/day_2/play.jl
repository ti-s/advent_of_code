
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
total_score(other::Shape, outcome::Outcome) = score(other, Shape(other, outcome)) + score(Shape(other, outcome))

abstract type Outcome end
struct Win <: Outcome end
struct Draw <: Outcome end
struct Loss <: Outcome end

Shape(other::Rock, outcome::Win) = Paper()
Shape(other::Rock, outcome::Loss) = Scissor()
Shape(other::Paper, outcome::Win) = Scissor()
Shape(other::Paper, outcome::Loss) = Rock()
Shape(other::Scissor, outcome::Win) = Rock()
Shape(other::Scissor, outcome::Loss) = Paper()
Shape(other::Shape, outcome::Draw) = other


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


function Outcome(s::Symbol)
    if s == :X
        return Loss()
    elseif s == :Y
        return Draw()
    elseif s == :Z
        return Win()
    else
        throw(DomainError("Invalid shape symbol: $s"))
    end
end


function parse_line(::Type{T}, ::Type{S}, line) where {T,S}
    first, second = Symbol.(split(line))
    return T(first), S(second)
end

function parse_input(::Type{T}, ::Type{S}, stream) where {T,S}
    return [parse_line(T, S, line) for line in eachline(stream)]
end

function play(games)
    sum(total_score(game...) for game in games)
end

games = parse_input(Shape, Shape, "$(dirname(@__FILE__))/input.txt")
println("Total score 1: $(play(games))")

games = parse_input(Shape, Outcome, "$(dirname(@__FILE__))/input.txt")
println("Total score 2: $(play(games))")