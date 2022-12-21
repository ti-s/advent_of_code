ops = Dict{String,Function}("+" => +, "-" => -, "*" => *, "/" => /)

function parse_monkey!(ms, line)
    global ops
    parts = split(line)
    name = Symbol(strip(parts[1], ':'))
    if length(parts) == 2
        number = parse(Int, parts[2])
        ms[name] = () -> number
    else
        m1 = Symbol(parts[2])
        op = ops[parts[3]]
        m2 = Symbol(parts[4])
        ms[name] = () -> op(ms[m1](), ms[m2]())
    end
    ms
end

function load_monkeys(parse!, stream)
    monkeys = Dict{Symbol,Function}()
    for line in stream
        parse!(monkeys, line)
    end
    monkeys
end

function parse_monkey2!(ms, line)
    global ops
    parts = split(line)
    name = Symbol(strip(parts[1], ':'))
    if name == :humn
        ms[name] = h -> h
    elseif length(parts) == 2
        number = parse(Int, parts[2])
        ms[name] = h -> number
    else
        m1 = Symbol(parts[2])
        op = name == :root ? (-) : ops[parts[3]]
        m2 = Symbol(parts[4])
        ms[name] = h -> op(ms[m1](h), ms[m2](h))
    end
    ms
end


function find_zero(f, x)
    # Assume that the answer is positive
    x1 = x
    y1 = f(x1)
    x2 = 2x
    y2 = f(x2)
    while sign(y1) == sign(y2)
        y1 == 0 && return x1
        y2 == 0 && return x2
        x1, x2 = x2, 2x2
        y1, y2 = y2, f(x2)
    end
    while true
        x1 == x2 && return nothing
        x3 = x1 + (x2 - x1) ÷ 2
        y3 = f(x3)
        y3 == 0 && return x3
        if sign(y1) == sign(y3)
            x1 = x3
            y1 = y3
        else
            x2 = x3
            y2 = y3
        end
    end
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    monkeys = load_monkeys(parse_monkey!, eachline(testfilename))
    test1 = Int(monkeys[:root]())

    monkeys = load_monkeys(parse_monkey2!, eachline(testfilename))
    root = find_zero(monkeys[:root], 1)
    test2 = Int(root)
    @show monkeys[:root](test2)

    monkeys = load_monkeys(parse_monkey!, eachline(filename))
    part1 = Int(monkeys[:root]())

    monkeys = load_monkeys(parse_monkey2!, eachline(filename))
    root = find_zero(monkeys[:root], 1)
    part2 = Int(root)
    @show monkeys[:root](part2)

    println("Test 1: ", test1)
    println("Test 2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
