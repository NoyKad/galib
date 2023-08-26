module main

import rand

// Genetic algorithm to find the maximum of a function
// TODO: the algorithm is working. However, it needs to be optimized
// by using a more efficient data structure for the population and 
// elevating the properties of the v language to the max.


struct Individual {
mut:
	chromosome []u8
	fitness    int
}

fn concatenate(mut array1 [][]u8, mut array2 [][]u8) ![][]u8 {
	mut joined := [][]u8{len: array1.len + array2.len}

	for i in 0 .. array1.len {
		joined[i] = array1[i]
	}

	for i in 0 .. array2.len {
		joined[i + array1.len] = array2[i]
	}

	return joined
}

fn init_individual(size int) ![]u8 {
	mut chromosome := []u8{len: size}

	for i in 0 .. size {
		chromosome[i] = u8(rand.binomial(1, 0.5)!)
	}

	return chromosome
}

fn genesis(pop_size int, chromosome_size int) ![][]u8 {
	mut population := [][]u8{len: pop_size}

	for i in 0 .. pop_size {
		population[i] = init_individual(chromosome_size)!
	}

	return population
}

fn single_crossover(parent1 []u8, parent2 []u8) ![]u8 {
	mut child := []u8{len: parent1.len}

	split := rand.int_in_range(0, parent1.len)!

	for i, gen in parent1 {
		if i < split {
			child[i] = gen
		} else {
			child[i] = parent2[i]
		}
	}

	return child
}

fn crossover(population [][]u8) ![][]u8 {
	mut new_population := [][]u8{len: population.len}

	for i in 0 .. population.len {
		parent1 := population[rand.int_in_range(0, population.len)!]
		parent2 := population[rand.int_in_range(0, population.len)!]

		new_population[i] = single_crossover(parent1, parent2)!
	}

	return new_population
}

fn single_mutation(mut chromosome []u8, mutation_rate f64) ![]u8 {
	proportion := int(mutation_rate * chromosome.len)
	assert proportion > 0, 'mutation rate too low'

	inx := []int{len: chromosome.len, init: index}
	mut inx2mut := []int{len: proportion, init: 0}

	inx2mut = rand.choose(inx, proportion)!

	// flip bits
	for i in inx2mut {
		chromosome[i] = 1 - chromosome[i]
	}

	return chromosome
}

fn mutation(mut population [][]u8, mutation_rate f64) ![][]u8 {
	for i in 0 .. population.len {
		population[i] = single_mutation(mut population[i], mutation_rate)!
	}

	return population
}

fn single_fitness(chromosome []u8) int {
	mut fitness := 0

	for i in chromosome {
		fitness += i
	}

	return fitness
}

fn fitness(population [][]u8) ![]int {
	mut fitness := []int{len: population.len}

	for i in 0 .. population.len {
		fitness[i] = single_fitness(population[i])
	}

	return fitness
}

fn sort_by_fitness(mut population [][]u8, mut fitness []int) ![][]u8 {
	mut struct_fitness := []Individual{len: population.len}
	mut new_population := [][]u8{len: population.len}

	for i in 0 .. population.len {
		struct_fitness[i] = Individual{
			chromosome: population[i]
			fitness: fitness[i]
		}
	}

	// sort by fitness
	struct_fitness.sort(a.fitness > b.fitness)

	for i, value in struct_fitness {
		new_population[i] = value.chromosome
	}

	return new_population
}

fn generation(mut population [][]u8, mutation_rate f64, elite_rate f64) ![][]u8 {
	n_elite := int(population.len * elite_rate)
	mut scores := fitness(population)!
	population = sort_by_fitness(mut population, mut scores)!

	mut elite := population[0..n_elite].clone()

	mut new_population := crossover(population[n_elite..])!
	new_population = mutation(mut new_population, mutation_rate)!
	return concatenate(mut elite, mut new_population)
}

fn main() {
	mut population := genesis(5000, 20)!

	for i in 0 .. 1000 {
		population = generation(mut population, 0.1, 0.1)!

		// print each 10 generations
		if i % 10 == 0 {
			println('Generation: ' + i.str() + ' Best individual: ' + population[0].str() +
				' with fitness: ' + single_fitness(population[0]).str())
		}
	}
	println('Best individual: ' + population[0].str() + ' with fitness: ' +
		single_fitness(population[0]).str())
}
