function mark_line_of_sight!(out, in)
    max = -1
    for i in eachindex(out, in)
        in[i] <= max && continue
        max = in[i]
        out[i] = true
    end
end


function visible(trees)
    out = similar(trees, Bool)
    out .= false
    width = size(trees, 2)
    for i = 1:width
        @views mark_line_of_sight!(out[:, i], trees[:, i])
        @views mark_line_of_sight!(out[i, :], trees[i, :])
        @views mark_line_of_sight!(out[end:-1:begin, i], trees[end:-1:begin, i])
        @views mark_line_of_sight!(out[i, end:-1:begin], trees[i, end:-1:begin])
    end
    out
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
    width = size(trees, 2)
    for i = 1:width
        @views score_line_of_sight!(out[:, i], trees[:, i])
        @views score_line_of_sight!(out[i, :], trees[i, :])
        @views score_line_of_sight!(out[end:-1:begin, i], trees[end:-1:begin, i])
        @views score_line_of_sight!(out[i, end:-1:begin], trees[i, end:-1:begin])
    end
    out
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
