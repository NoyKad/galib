// write genetic algorithm with uses only binary representation

package main

import (
	"fmt"
	"math/rand"
	// "time"
)

const (
	POPULATION_SIZE = 100
	CHROMOSOME_SIZE = 10
	MAX_GENERATIONS = 100
)

type Chromosome struct {
	genes []int
	fitness int
}

func (c *Chromosome) Init() {
	c.genes = make([]int, CHROMOSOME_SIZE)

	for i := 0; i < CHROMOSOME_SIZE; i++ {
		c.genes[i] = rand.Intn(2)
	}
}

func (c *Chromosome) CalcFitness() {
	c.fitness = 0
	for i := 0; i < CHROMOSOME_SIZE; i++ {
		c.fitness += c.genes[i]
	}
}

func (c *Chromosome) Print() {
	for i := 0; i < CHROMOSOME_SIZE; i++ {
		fmt.Print(c.genes[i])
	}
	fmt.Println(" ", c.fitness)
}

func (c *Chromosome) Crossover(c2 *Chromosome) *Chromosome {
	c3 := new(Chromosome)
	c3.Init()
	for i := 0; i < CHROMOSOME_SIZE; i++ {
		if rand.Intn(2) == 0 {
			c3.genes[i] = c.genes[i]
		} else {
			c3.genes[i] = c2.genes[i]
		}
	}
	return c3
}

func (c *Chromosome) Mutate() {
	for i := 0; i < CHROMOSOME_SIZE; i++ {
		if rand.Intn(100) == 0 {
			c.genes[i] = 1 - c.genes[i]
		}
	}
}

func main() {

	// rand.Seed(time.Now().UnixNano())

	population := make([]*Chromosome, POPULATION_SIZE)
	for i := 0; i < POPULATION_SIZE; i++ {
		population[i] = new(Chromosome)
		population[i].Init()
		population[i].CalcFitness()
	}

	for generation := 0; generation < MAX_GENERATIONS; generation++ {

		// sort population
		for i := 0; i < POPULATION_SIZE; i++ {
			for j := 0; j < POPULATION_SIZE - 1; j++ {
				if population[j].fitness < population[j + 1].fitness {
					population[j], population[j + 1] = population[j + 1], population[j]
				}
			}
		}

		// print best chromosome
		population[0].Print()

		// create new population
		newPopulation := make([]*Chromosome, POPULATION_SIZE)
		for i := 0; i < POPULATION_SIZE; i++ {
			newPopulation[i] = new(Chromosome)
			newPopulation[i].Init()
		}

		// crossover
		for i := 0; i < POPULATION_SIZE / 2; i++ {
			newPopulation[i * 2] = population[i * 2].Crossover(population[i * 2 + 1])
			newPopulation[i * 2 + 1] = population[i * 2 + 1].Crossover(population[i * 2])
		}

		// mutate
		for i := 0; i < POPULATION_SIZE; i++ {
			newPopulation[i].Mutate()
			newPopulation[i].CalcFitness()
		}

		// copy new population
		for i := 0; i < POPULATION_SIZE; i++ {
			population[i] = newPopulation[i]
		}
	}
}
