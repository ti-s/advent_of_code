mutable struct CPU
    registers::Vector{Int}
end


function add!(cpu, register, value)
    cpu.registers[register] += value
end

function noop!(cpu, register, value)
    nothing
end


function parse_instruction(line)
    cmd, args... = split(line)
    if cmd == "addx"
        2, add!, 1, parse(Int, args[1])
    elseif cmd == "noop"
        1, noop!, 1, 0
    end
end


function parse_file(file)
    [parse_instruction(line) for line in eachline(file)]
end

function draw_pixel!(crt, cycle, x)
    pixel_per_row = size(crt, 1)
    pos = (cycle - 1) % pixel_per_row
    crt[cycle] =
        if pos in sprite(x)
            '#'
        else
            '.'
        end
    crt
end


function execute!(cpu, instructions, crt)
    cycles = length(crt)
    history = Vector{Vector{Int}}(undef, cycles)
    cycle = 0
    for (duration, op!, register, value) in instructions
        for i in 1:duration
            cycle += 1
            cycle > cycles && break
            draw_pixel!(crt, cycle, cpu.registers[1])
            history[cycle] = copy(cpu.registers)
        end
        op!(cpu, register, value)
    end
    history
end

function sprite(middle)
    middle-1:middle+1
end

function draw(crt)
    println("CRT shows:")
    for i in axes(crt, 2)
        println(String(crt[:, i]))
    end
    println()
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    cpu = CPU([1])
    crt = Array{Char}(undef, 40, 6)
    instructions = parse_file(testfilename)
    history = execute!(cpu, instructions, crt)
    test = sum(i * history[i] for i in [20; 60:40:220])
    println("Test: ", test)
    draw(crt)

    cpu = CPU([1])
    crt = Array{Char}(undef, 40, 6)
    instructions = parse_file(filename)
    history = execute!(cpu, instructions, crt)
    part1 = sum(i * history[i] for i in [20; 60:40:220])
    println("Part 1: ", part1)
    draw(crt)
end

main()
