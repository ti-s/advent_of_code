using Base.Iterators
import Base: iterate, IteratorSize, isdone, SizeUnknown, IteratorEltype, EltypeUnknown

struct EachElf{T}
    itr::T
end

function iterate(itr::EachElf, state=nothing)
    isdone(itr.itr) && return nothing
    (takewhile(!isempty, itr.itr), nothing)
end

IteratorSize(::Type{<:EachElf}) = SizeUnknown()
IteratorEltype(::Type{<:EachElf}) = EltypeUnknown()
isdone(itr::EachElf) = isdone(itr.itr)

function eachelf(stream)
    EachElf(eachline(stream))
end


function get_sums_by_elf(stream)
    [sum(l -> parse(Int, l), elf) for elf in eachelf(stream)]
end

sums_by_elf = get_sums_by_elf("input.txt")
top3 = partialsort(sums_by_elf, 1:3, rev=true)

println("Most calories: $(top3[1])")

println("Sum top 3: $(sum(top3))")

	
