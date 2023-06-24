using Random
using Images

# read image from file using Images.jl
function load_image_as_array(filename)
    # out = convert(Array{UInt8}, load(filename))
    out = load(filename)
    out = convert(Array{UInt8}, ifelse.(out .> 0, 1, 0))
    return out
end

struct GeneticAlgorithm
    image_shape::Tuple{Vararg{Int}}
    target::Array{UInt8}
    population_size::Int
    generations::Int
    elite_size::Int
    mutation_size::Int
    mutation_arr_size::Int
    population::Array{UInt8}
    score::Array{Float64}
end

function GeneticAlgorithm(image::Array{UInt8}, population_size::Int, elite_rate::Float64, mutation_pop_rate::Float64, mutation_arr_rate::Float64, generations::Int)
    image_shape = size(image)
    target = convert(Array{UInt8}, ifelse.(image .> 0, 1, 0))
    elite_size = Int(population_size * elite_rate)
    mutation_size = Int(population_size * mutation_pop_rate)
    mutation_arr_size = Int(prod(size(target)) * mutation_arr_rate)
    population = rand([0, 1], (population_size, prod(size(target))))
    score = ones(population_size) * Inf

    return GeneticAlgorithm(image_shape, target, population_size, generations, elite_size, mutation_size, mutation_arr_size, population, score)
end

function genesis(ga::GeneticAlgorithm)
    ga.population = rand([0, 1], size(ga.population))
    ga.score = ones(ga.population_size) * Inf
end

function single_mutation(individual::Array{UInt8}, ga::GeneticAlgorithm)
    inx = rand(1:length(individual), ga.mutation_arr_size)
    individual[inx] = rand([0, 1], length(inx))
    return individual
end

function mutation(population::Array{UInt8}, ga::GeneticAlgorithm)
    population = [single_mutation(individual, ga) for individual in population]
    return population
end

function single_crossover(parent1::Array{UInt8}, population::Array{UInt8}, ga::GeneticAlgorithm)
    inx = rand(1:length(ga.target))
    parent2 = population[rand(1:size(population, 1)), :]
    return vcat(parent1[1:inx], parent2[inx+1:end])
end

function per_item_all(parent1::Array{UInt8}, population::Array{UInt8}, ga::GeneticAlgorithm)
    parent2 = population[rand(1:size(population, 1)), :]
    return ifelse.(parent1 .== parent2, parent1, rand([0, 1], size(parent1)))
end

function crossover(population::Array{UInt8}, ga::GeneticAlgorithm)
    return [per_item_all(parent1, population, ga) for parent1 in population]
end

function fitness(population::Array{UInt8}, ga::GeneticAlgorithm)
    ga.score = mean((population .- ga.target).^2, dims=2)[:]
end

function sort_population(population::Array{UInt8}, ga::GeneticAlgorithm)
    fitness(population, ga)
    sorted_inx = sortperm(ga.score)
    return population[sorted_inx, :]
end

function run(ga::GeneticAlgorithm)
    genesis(ga)
    ga.best_score = Inf

    for i in 1:ga.generations
        ga.population = sort_population(ga.population, ga)

        elite = ga.population[1:ga.elite_size, :]

        new_population = crossover(ga.population[ga.elite_size+1:end, :], ga)

        inx_to_mutate = rand(1:size(new_population, 1), ga.mutation_size)
        new_population[inx_to_mutate, :] = mutation(new_population[inx_to_mutate, :], ga)

        ga.population = vcat(elite, new_population)

        if minimum(ga.score) < ga.best_score
            ga.best_score = minimum(ga.score)
            println("Gen. $i: Best individual: $(minimum(ga.score))")
            if ga.best_score == 0
                break
            end
        end
    end

    println("Run Ended at Gen. $i: Best individual: $(minimum(ga.score))")
    return sort_population(ga.population, ga)
end

# Usage example
image = load_image_as_array("/com.docker.devenvironments.code/data/docker_1ch_s10x10.png")
ga = GeneticAlgorithm(image, 100, 0.1, 0.1, 0.1, 100)
run(ga)
