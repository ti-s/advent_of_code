oneissubset(a, b) = issubset(a, b) || issubset(b, a)  # issubset for ranges is efficient
parse_range(str) = range(parse.(Int, split(str, "-"))...)

function overlap(a, b)
    length(a) + length(b) > length(min(first(a), first(b)):max(last(a), last(b)))
end

lines = readlines(joinpath(@__DIR__, "input.txt"))

ranges = (parse_range.(split(line, ",")) for line in lines)

println("Subsets: ", count(oneissubset(rs...) for rs in ranges))

println("Overlaps: ", count(overlap(rs...) for rs in ranges))