using CircularArrays

# First implementation based on CircularArrays

# CircularArrays don't support insertion
function Base.insert!(a::CircularVector, i::Integer, v)
    j = mod(i, eachindex(IndexLinear(), a.data))
    if j == 1
        # prefer inserting at the end instead of at the front to match the example
        j = length(a.data) + 1
    end
    insert!(a.data, j, v)
    a
end

function decrypt!(initial, indices::CircularVector, numbers::CircularVector)
    for (ind, number) in pairs(initial)
        if number == 0
            continue
        end
        i = findfirst(==(ind), indices)
        j = i + number
        deleteat!(numbers, i)
        deleteat!(indices, i)
        insert!(numbers, j, number)
        insert!(indices, j, ind)
    end
    numbers
end

function find_coords(input, key=1, rounds=1)
    input = key * input
    circular_indices = CircularVector(collect(axes(input, 1)))
    circular_numbers = CircularVector(copy(input))
    for _ = 1:rounds
        decrypt!(input, circular_indices, circular_numbers)
    end
    i = findfirst(==(0), circular_numbers)
    sum(circular_numbers[i.+[1000, 2000, 3000]])
end


# Second manual implementation for debugging

function move_number!(array, i, n, show=false)
    if n == 0
        show && println("$n does not move:")
        show && println(array)
        show && println()
        return array
    end
    number = popat!(array, i)
    j = mod(i + n, axes(array, 1))
    prev = mod(j - 1, axes(array, 1))
    show && println("$n moves between $(array[prev]) and $(array[j]):")
    if j == 1
        # prefer inserting at the end instead of the front
        j = size(array, 1) + 1
    end
    insert!(array, j, number)
    show && println(array)
    show && println()
end

function decrypt2!(indices, numbers, show=false)
    for i in axes(numbers, 1)
        ind = findfirst(==(i), indices)
        number = numbers[ind]
        move_number!(numbers, ind, number, show)
        move_number!(indices, ind, number, false)
    end
    numbers
end

function find_coords2(numbers, key=1, rounds=1; show=false)
    numbers = numbers * key
    indices = collect(axes(numbers, 1))
    show && println("Initial arrangement:")
    show && println(numbers)
    show && println()
    for r = 1:rounds
        decrypt2!(indices, numbers, show && rounds == 1)
        show && println("After $r rounds of mixing:")
        show && println(numbers)
        show && println()
    end
    i = findfirst(==(0), numbers)
    inds = i .+ [1000, 2000, 3000]
    sum(numbers[mod(i, axes(numbers, 1))] for i in inds)
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    input = [parse(Int, line) for line in eachline(testfilename)]
    test1 = find_coords2(input, show=true)
    test2 = find_coords2(input, 811589153, 10, show=true)

    input = [parse(Int, line) for line in eachline(filename)]
    part1 = find_coords(input)
    part2 = find_coords(input, 811589153, 10)

    println("Test1: ", test1)
    println("Test2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
