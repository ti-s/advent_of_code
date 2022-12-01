
parse_list(type, str) = parse.(type, split(str))


function get_sums_by_elf(filename)
    text = read(filename, String)
    text_by_elf = split(text, "\n\n")

    return sum.(parse_list.(Int, text_by_elf))
end

sums_by_elf = get_sums_by_elf("input.txt")
top3 = partialsort(sums_by_elf, 1:3, rev=true)

println("Most calories: $(top3[1])")

println("Sum top 3: $(sum(top3))")
