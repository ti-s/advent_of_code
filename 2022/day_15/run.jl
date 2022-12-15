const Pos = CartesianIndex{2}

struct Record
    sensor::Pos
    beacon::Pos
    range::Int
    Record(s::Pos, b::Pos) = new(s, b, distance(s, b))
end

distance(p::Pos, q::Pos) = abs(p[1] - q[1]) + abs(p[2] - q[2])

function parse_record(line)
    m = match(r"x=(?<sx>-?\d+).+y=(?<sy>-?\d+).+x=(?<bx>-?\d+).+y=(?<by>-?\d+)", line)
    sx, sy, bx, by = parse.(Int, m)
    Record(Pos(sy, sx), Pos(by, bx))
end

parse_records(stream) = [parse_record(line) for line in stream]

iscovered(r::Record, pos::Pos) = distance(r.sensor, pos) <= r.range
iscovered(rs, pos) = any(r -> iscovered(r, pos), rs)

beacons(rs) = Set(r.beacon for r in rs)

isbeacon(rs, pos) = pos in beacons(rs)

max_range(rs) = maximum(r.range for r in rs)
min_x(rs) = minimum(r.sensor[2] for r in rs) - max_range(rs)
max_x(rs) = maximum(r.sensor[2] for r in rs) + max_range(rs)


function cover_range(r::Record, row)
    vertical_distance = abs(r.sensor[1] - row)
    col = r.sensor[2]
    first = col - (r.range - vertical_distance)
    last = col + (r.range - vertical_distance)
    first:last
end

function count_covered(rs, row, columns)
    count = 0
    col = first(columns)
    while col in columns
        for r in rs
            covered_cols = cover_range(r, row)
            if col in covered_cols
                next = last(covered_cols) + 1
                # don't jump over the edge of the column range
                next = min(next, last(columns))
                count += next - col
                col = next
            end
        end
        count += iscovered(rs, Pos(row, col))
        col += 1
    end
    count
end

count_beacons(rs, row) = count(b -> b[1] == row, beacons(rs))

function find_uncovered_beacon(rs, rows, columns)
    for row in rows
        count = count_covered(rs, row, columns)
        if count < length(columns)
            # this row has uncovered positions
            # find the uncovered column
            for col in columns
                if !iscovered(rs, Pos(row, col))
                    return Pos(row, col)
                end
            end
        end
    end
end

tuning_frequency(beacon) = beacon[2] * 4000000 + beacon[1]


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    records = parse_records(eachline(testfilename))
    row = 10
    test1 = count_covered(records, row, min_x(records):max_x(records)) - count_beacons(records, row)
    beacon = find_uncovered_beacon(records, 0:20, 0:20)
    test2 = tuning_frequency(beacon)

    records = parse_records(eachline(filename))
    row = 2000000
    part1 = count_covered(records, row, min_x(records):max_x(records)) - count_beacons(records, row)
    beacon = find_uncovered_beacon(records, 0:4000000, 0:4000000)
    part2 = tuning_frequency(beacon)

    println("Test 1: ", test1)
    println("Part 1: ", part1)
    println("Test 2: ", test2)
    println("Part 2: ", part2)
end

main()
