using Combinatorics
using Graphs

struct Valve
    name::Symbol
    flow::Int
end

function parse_line(line)
    name, edges... = [line[I] for I in findall(r"[A-Z][A-Z]", line)]
    flow = line[findfirst(r"\d+", line)]
    Valve(Symbol(name), parse(Int, flow)), Symbol.(edges)
end

get_name(valves, i) = valves[i].name
get_flow(valves, i) = valves[i].flow
get_index(valves, name) = searchsortedfirst(valves, Valve(name, 0), by=v -> v.name)

function load_valves(stream)
    valves_and_edges = ([parse_line(line) for line in stream])
    # sort for faster get_index
    sort!(valves_and_edges; by=t -> t[1].name)
    valves = first.(valves_and_edges)
    edges = last.(valves_and_edges)

    graph = SimpleGraph(length(valves_and_edges))

    for i in eachindex(valves)
        for edge in edges[i]
            j = get_index(valves, edge)
            add_edge!(graph, i, j)
        end
    end
    valves, graph
end


function get_relevant_indices(valves)
    working_indices = [get_index(valves, v.name) for v in valves if v.flow > 0]
    [1; working_indices]
end

function create_distance_matrix(graph, indices)
    N = length(indices)
    distance_matrix = Matrix{Int}(undef, N, N)
    for (i, s) in enumerate(indices)
        distances = gdistances(graph, s)
        for (j, t) in enumerate(indices)
            distance_matrix[i, j] = distances[t]
        end
    end
    distance_matrix
end

function load_input(filename)
    valves, graph = load_valves(eachline(filename))
    relevant_indices = get_relevant_indices(valves)
    distmat = create_distance_matrix(graph, relevant_indices)
    valves[relevant_indices], distmat
end


function pressure_release(distmat, i, indices, valves, total, time)
    if time <= 0
        return [valves[i].name], total
    end
    if isempty(indices)
        return [valves[i].name], total + valves[i].flow * time
    end
    max_press = 0
    max_path = Symbol[]
    for j in indices
        dist = distmat[i, j]
        duration = dist + 1
        new_total = total + valves[i].flow * time
        new_time = time - duration
        new_indices = filter(!=(j), indices)
        path, press = pressure_release(
            distmat, j, new_indices, valves, new_total, new_time)
        if press > max_press
            max_press = press
            max_path = path
        end
    end
    return pushfirst!(max_path, valves[i].name), max_press
end

function pressure_all_sets(distmat, start, indices, valves, total, time)
    max_p = 0
    max_path1 = Symbol[]
    max_path2 = Symbol[]
    for (part1, part2) in partitions(indices, 2)
        path1, press1 = pressure_release(distmat, start, part1, valves, total, time)
        path2, press2 = pressure_release(distmat, start, part2, valves, total, time)
        press = press1 + press2
        if press > max_p
            max_p = press
            max_path1 = path1
            max_path2 = path2
        end
    end
    return max_path1, max_path2, max_p
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    valves, distmat = load_input(testfilename)
    path, total = pressure_release(distmat, 1, 2:length(valves), valves, 0, 30)
    test = path, total

    valves, distmat = load_input(filename)
    path, total = pressure_release(distmat, 1, 2:length(valves), valves, 0, 30)
    part1 = path, total

    part2 = pressure_all_sets(distmat, 1, 2:length(valves), valves, 0, 26)
    println("Test: ", test)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
