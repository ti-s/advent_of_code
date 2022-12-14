using JSON

parse_packet(line) = JSON.parse(line)

function parse_packets(stream)
    packets = Vector()
    for line in stream
        left = parse_packet(line)
        right = parse_packet(first(stream))
        push!(packets, left => right)
        !isempty(stream) && first(stream)
    end
    packets
end

compare(left::Int, right::Int) = cmp(left, right)
function compare(left, right)
    for (l, r) in zip(left, right)
        ret = compare(l, r)
        ret == 0 && continue
        return ret
    end
    return cmp(length(left), length(right))
end

isordered(left, right) = compare(left, right) < 0


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    packets = parse_packets(eachline(testfilename))
    test = sum(i for (i, (l, r)) in enumerate(packets) if isordered(l, r))
    println("Test: ", test)

    packets = parse_packets(eachline(filename))
    part1 = sum(i for (i, (l, r)) in enumerate(packets) if isordered(l, r))
    println("Part 1: ", part1)

    packets = collect(Iterators.flatten(packets))
    push!(packets, [[2]], [[6]])
    sort!(packets, lt=isordered)
    a = findfirst(==([[2]]), packets)
    b = findfirst(==([[6]]), packets)
    part2 = a * b
    println("Part 2: ", part2)
end

main()
