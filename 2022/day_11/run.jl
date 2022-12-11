struct Monkey
    items::Vector{Int}
    operation
    divisor::Int
    target_true::Int
    target_false::Int
end

parse_items(line) = parse.(Int, split(split(line, ":")[2], ","))
parse_test(line) = parse(Int, split(line)[end])
parse_target(line) = parse(Int, split(line)[end]) + 1

function parse_operation(line)
    expr = Meta.parse(split(line, ":")[2])
    # turn "new = f(old)" into "old -> f(old)"
    expr.head = Symbol("->")
    expr.args[1] = Symbol("old")
    eval(expr)
end

function parse_monkey(stream)
    isempty(stream) && return nothing
    first(stream) # header
    items = parse_items(first(stream))
    operation = parse_operation(first(stream))
    divisor = parse_test(first(stream))
    target_true = parse_target(first(stream))
    target_false = parse_target(first(stream))
    Monkey(items, operation, divisor, target_true, target_false)
end

function parse_monkeys(stream)
    monkey = parse_monkey(stream)
    monkeys = [monkey]
    # remove empty line
    isempty(stream) && return monkeys
    first(stream)
    while true
        monkey = parse_monkey(stream)
        isnothing(monkey) && break
        push!(monkeys, monkey)
        # remove empty line
        isempty(stream) && break
        first(stream)
    end
    monkeys
end


function throw!(monkey, relief)
    isempty(monkey.items) && return nothing
    item = popfirst!(monkey.items)
    item = monkey.operation(item)
    item = relief(item)
    target =
        if item % monkey.divisor == 0
            monkey.target_true
        else
            monkey.target_false
        end
    item, target
end

function catch!(monkey, item)
    push!(monkey.items, item)
end

function throw_all!(monkey, relief)
    (throw!(monkey, relief) for _ = 1:length(monkey.items))
end

function play!(monkeys, rounds, relief)
    counts = zeros(Int, size(monkeys))
    for round in 1:rounds
        for (i, monkey) in enumerate(monkeys)
            for (item, target) in throw_all!(monkey, relief)
                counts[i] += 1
                catch!(monkeys[target], item)
            end
        end
    end
    counts
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    monkeys = parse_monkeys(eachline(testfilename))
    # parse_monkeys defined new functions that are not evailable in the current
    # world age. The world is increased when hitting top level or by calling
    # invokelatest in the current function
    counts = Base.@invokelatest play!(monkeys, 20, x -> x ÷ 3)
    sort!(counts)
    test = counts[end-1] * counts[end]

    monkeys = parse_monkeys(eachline(filename))
    counts = sort(Base.@invokelatest play!(monkeys, 20, x -> x ÷ 3))
    part1 = counts[end-1] * counts[end]

    monkeys = parse_monkeys(eachline(filename))
    common_divisor = prod(m.divisor for m in monkeys)
    counts = sort(Base.@invokelatest play!(monkeys, 10000, x -> x % common_divisor))
    part2 = counts[end-1] * counts[end]

    println("Test: ", test)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
