using Base.Iterators

function compartments(line)
    len = length(line)
    mid = len ÷ 2
    first_half = line[begin:mid]
    second_half = line[mid+1:end]
    return first_half, second_half
end

function priority(item)
    if isuppercase(item)
        Int(item) - Int('A') + 27
    else
        Int(item) - Int('a') + 1
    end
end

function common(itrs)
    only(intersect(itrs...))
end

lines = readlines("$(@__DIR__)/input.txt")

println("Part 1: ", sum(priority ∘ common ∘ compartments, lines))

println("Part 2: ", sum(priority ∘ common, partition(lines, 3)))