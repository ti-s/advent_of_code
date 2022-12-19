using LinearAlgebra
using StaticArrays
using JuMP
using HiGHS


const Vec4 = SVector{4,Int8}

const production = (
    Vec4(1, 0, 0, 0),  # geodes
    Vec4(0, 1, 0, 0),  # obsidian
    Vec4(0, 0, 1, 0),  # clay
    Vec4(0, 0, 0, 1),  # ore
    # Vec4(0, 0, 0, 0),  # no robot
)

function parse_line(line)
    number = [parse(Int, line[I]) for I in findall(r"(\d+)", line)]
    id = number[1]
    costs = (
        Vec4(0, number[7], 0, number[6]),  # geodes
        Vec4(0, 0, number[5], number[4]),  # obsidian
        Vec4(0, 0, 0, number[3]),          # clay
        Vec4(0, 0, 0, number[2]),          # ore
        # Vec4(0, 0, 0, 0)                   # no robot
    )
    id, costs
end


function create_model(costs, steps)
    model = Model(HiGHS.Optimizer)
    # variables x_ij are the binary decisions to build a robot of type j at step i
    @variable(model, x[1:steps, 1:length(costs)], Bin)
    # cumsum(x[:, i]) is the production of resource i at each step
    # maximize the total production of geodes
    @objective(model, Max, sum(cumsum(x[:, 1])))
    # costs and production values of robots need to be a matrix
    cost_matrix = reinterpret(reshape, eltype(Vec4), [costs...])
    prod_matrix = reinterpret(reshape, eltype(Vec4), [production...])
    for i = 1:steps
        # we can only build at most one robot
        @constraint(model, sum(x[i, :]) <= 1)
        # we cannot spent more than what we produced
        for c in eachindex(costs)
            # add one ore production per step from the robot we already have
            extra_ore = (c == 4) * (i - 1)
            # delay production from a new robot by one step
            f(i, j) = i - j - 1 > 0 ? i - j - 1 : 0
            @constraint(model, extra_ore + sum((f(i, j) * prod_matrix[c, :] - cost_matrix[c, :]) ⋅ x[j, :] for j = 1:i) >= 0)
        end
    end
    model, x
end

function describe_solution(costs, x)
    names = ["geodes", "obsidian", "clay", "ore"]
    cost_matrix = reinterpret(reshape, eltype(Vec4), [costs...])
    prod_matrix = reinterpret(reshape, eltype(Vec4), [production...])
    inventory = Vec4(0, 0, 0, 0)
    income = Vec4(0, 0, 0, 1)
    for (i, row) in enumerate(eachrow(x))
        println("== Minute $i ==")
        @assert all(>=(-0.1), row)
        @assert all(<=(1.1), row)
        @assert -0.1 <= sum(row) <= 1.1
        if sum(row) < 0.5
            cost = Vec4(0, 0, 0, 0)
            prod = Vec4(0, 0, 0, 0)
        else
            robot = findfirst(>=(0.5), row)
            println("Start to build robot for $(names[robot])")
            cost = costs[findfirst(>=(0.5), row)]
            prod = production[findfirst(>=(0.5), row)]
        end
        inventory -= cost
        @assert all(>=(0), inventory)
        inventory += income
        for j = 1:4
            if income[j] > 0
                println("robots collect $(income[j]) $(names[j]); there are now $(inventory[j]) $(names[j])")
            end
        end
        income += prod
        @show i, inventory, income
        println()
    end
end

function maximize_geodes(blueprints, production, steps)
    quality_sum = 0
    quality_prod = 1
    for (id, costs) in blueprints
        @show id, costs
        # - 1 because the objective is evaluated *after* the last step
        model, x = create_model(costs, steps - 1)
        optimize!(model)
        @show max_geodes = round(Int, objective_value(model))
        @assert max_geodes ≈ objective_value(model)
        quality_sum += id * max_geodes
        quality_prod *= max_geodes
        println()
    end
    quality_sum, quality_prod
end

# Trying every possible build order takes too long (> 5 min for blueprint 2)
# Returning early when the current build order clearly makes no sense helps for part 1
# but is still too slow for part 2 (probably there are smarter constraints for returning early)

# function is_inventory_too_large(inventory::Vec4, income, max_costs)
#     for i = 2:4  # no constrainsts on geodes
#         income[i] == 0 && continue  # we can't save this resource
#         if inventory[i] < max_costs[i] + income[i] + 1 # +1 to account for production last minute
#             # there is a robot we can save for
#             return false
#         end
#     end
#     # there is no robot we can save for with the current income
#     # saving more makes no sense
#     return true
# end

# function is_income_too_large(income, max_costs)
#     for i = 2:4  # no constraints on geodes
#         income[i] > max_costs[i] && return true  # we can only build one robot per minute
#     end
#     return false
# end

# function maximize_geodes(costs, max_costs, production, inventory, income, remaining_time)
#     is_income_too_large(income, max_costs) && return income, inventory
#     is_inventory_too_large(inventory, income, max_costs) && return income, inventory
#     if remaining_time <= 0
#         return income, inventory
#     end
#     remaining_time -= 1
#     max_income = Vec4(0, 0, 0, 0)
#     max_inventory = Vec4(0, 0, 0, 0)
#     for i in 1:5
#         new_inventory = inventory - costs[i]
#         if any(new_inventory .< 0)
#             continue
#         end
#         new_inventory += income
#         new_income = income + production[i]
#         res = maximize_geodes(costs, max_costs, production, new_inventory, new_income, remaining_time)
#         if res[2] > max_inventory
#             max_income, max_inventory = res
#         end
#     end
#     max_income, max_inventory
# end

# function maximize_geodes(blueprints, production, remaining_time)
#     max_id = 0
#     max_income = Vec4(0, 0, 0, 0)
#     max_inventory = Vec4(0, 0, 0, 0)
#     quality_sum = 0
#     for (id, costs) in blueprints
#         @show id, costs
#         max_costs = maximum(reinterpret(reshape, eltype(eltype(costs)), [costs...]), dims=2)
#         inventory = Vec4(0, 0, 0, 0)
#         income = Vec4(0, 0, 0, 1)
#         @show res = maximize_geodes(costs, max_costs, production, inventory, income, remaining_time)
#         if res[2] > max_inventory
#             max_income, max_inventory = res
#             max_id = id
#         end
#         quality_sum += id * res[2][1]
#     end
#     quality_sum, max_id, max_income, max_inventory
# end


function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    blueprints = [parse_line(line) for line in eachline(testfilename)]
    quality_sum, quality_prod = maximize_geodes(blueprints, production, 24)
    test1 = quality_sum

    quality_sum, quality_prod = maximize_geodes(blueprints, production, 32)
    test2 = quality_prod

    blueprints = [parse_line(line) for line in eachline(filename)]
    quality_sum, quality_prod = maximize_geodes(blueprints, production, 24)

    part1 = quality_sum

    blueprints = blueprints[1:3]
    quality_sum, quality_prod = maximize_geodes(blueprints, production, 32)
    part2 = quality_prod

    println("Test 1: ", test1)
    println("Test 2: ", test2)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
