using Base.Iterators

function wrong_item(rucksack)
    len = length(rucksack)
    mid = len ÷ 2
    first_half = rucksack[begin:mid]
    second_half = rucksack[mid+1:end]
    return only(intersect(first_half, second_half))
end

function priority(item)
    if isuppercase(item)
        Int(item) - Int('A') + 27
    else
        Int(item) - Int('a') + 1
    end
end

function find_badge(rucksacks)
    only(intersect(rucksacks...))
end

file = "$(@__DIR__)/input.txt"

println("Part 1: ", sum(priority ∘ wrong_item, eachline(file)))

println("Part 2: ", sum(priority ∘ find_badge, partition(eachline(file), 3)))