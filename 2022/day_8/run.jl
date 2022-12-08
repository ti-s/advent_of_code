function mark_line_of_sight!(out, in)
    max = -1
    for i in eachindex(out, in)
        in[i] <= max && continue
        max = in[i]
        out[i] = true
    end
end


function apply_all_directions!(f!, out, in)
    h, w = size(in)
    for i = 1:h
        @views f!(out[i, :], in[i, :])
        @views f!(out[i, end:-1:begin], in[i, end:-1:begin])
    end
    for i = 1:w
        @views f!(out[:, i], in[:, i])
        @views f!(out[end:-1:begin, i], in[end:-1:begin, i])
    end
    out
end


function visible(trees)
    out = similar(trees, Bool)
    out .= false
    apply_all_directions!(mark_line_of_sight!, out, trees)
end


function score_line_of_sight!(out, in)
    scores = zeros(Int, 10)
    for i in eachindex(out, in)
        v = in[i]
        out[i] *= scores[v+1]
        scores[1:(v+1)] .= 1
        scores[(v+2):10] .+= 1
    end
end


function scores(trees)
    out = ones(Int, size(trees))
    apply_all_directions!(score_line_of_sight!, out, trees)
end


function load_array(lines)
    width = length(first(lines))
    height = length(lines)
    [parse(Int, lines[i][j]) for i = 1:height, j = 1:width]
end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    test_trees = load_array(readlines(testfilename))
    test1 = count(visible(test_trees))
    test2 = maximum(scores(test_trees))

    trees = load_array(readlines(filename))
    part1 = count(visible(trees))
    part2 = maximum(scores(trees))

    println("Test 1: ", test1)
    println("Test 2: ", test2)

    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
