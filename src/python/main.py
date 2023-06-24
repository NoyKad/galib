from random import sample

import numpy as np
from PIL import Image

# np.random.seed(0)


# read image from file using numpy
def load_image_as_array(filename):
    out = np.array(Image.open(filename))
    out = np.where(out > 0, 1, 0)
    return out.astype(np.uint8)


class GeneticAlgorithm:
    def __init__(
        self,
        image: np.array,
        population_size: int,
        elite_rate: float,
        mutation_pop_rate: float,
        mutation_arr_rate: float,
        generations: int,
    ):
        self.image_shape = image.shape
        self.target = np.where(image > 0, 1, 0).flatten()
        self.population_size = population_size
        self.generations = generations
        self.elite_size = int(self.population_size * elite_rate)
        self.mutation_size = int(self.population_size * mutation_pop_rate)
        self.mutation_arr_size = int(self.target.size * mutation_arr_rate)

    def genesis(self):
        self.population = np.random.choice([0, 1], size=(self.population_size, self.target.size)).astype(np.uint8)
        self.score = np.ones(self.population_size) * np.inf

    def single_mutation(self, individual: np.array):
        inx = np.random.choice(np.arange(individual.size), size=self.mutation_arr_size)
        individual[inx] = np.random.choice([0, 1], size=inx.size)
        return individual

    def mutation(self, population: np.array):
        # population (to mutate) is a subset of the self.population
        population = np.apply_along_axis(func1d=self.single_mutation, axis=1, arr=population)

        return population

    def single_crossover(self, parent1: np.array, population: np.array):
        # implement single point crossover
        inx = np.random.choice(np.arange(self.target.size))
        patent2 = population[np.random.choice(np.arange(population.shape[0]))]
        return np.concatenate((parent1[:inx], patent2[inx:]))

    def per_item_all(self, parent1: np.array, population: np.array):
        patent2 = population[np.random.choice(np.arange(population.shape[0]))]
        return np.where(parent1 == patent2, parent1, np.random.choice([0, 1], size=parent1.size))

    def crossover(self, population: np.array):
        # population (to crossover) is a subset of the self.population
        return np.apply_along_axis(func1d=self.per_item_all, axis=1, arr=population, population=population)

    def fitness(self, population: np.array):
        self.score = np.square(population - self.target).mean(axis=1)

    def sort_population(self, population: np.array):
        self.fitness(population)
        sorted_inx = np.argsort(self.score)
        return population[sorted_inx]

    def run(self):
        self.genesis()
        self.best_score = np.inf

        for i in range(1, self.generations + 1):
            # sort the population by the fitness score
            self.population = self.sort_population(self.population)

            # get the elite
            elite = self.population[: self.elite_size]

            # crossover
            new_population = self.crossover(self.population[: -self.elite_size])

            # mutation
            inx_to_mutate = np.random.choice(np.arange(new_population.shape[0]), size=self.mutation_size)
            new_population[inx_to_mutate] = self.mutation(new_population[inx_to_mutate])

            # new population
            assert elite.shape[0] + new_population.shape[0] == self.population_size
            self.population = np.concatenate((elite, new_population))

            if self.score.min() < self.best_score:
                self.best_score = self.score.min()
                print(f"Gen. {i}: Best individual: {self.score.min()}")
                if self.best_score == 0:
                    break
                    
        print(f"Run Ended at Gen. {i}: Best individual: {self.score.min()}")
        return self.sort_population(self.population)


if __name__ == "__main__":
    path = "data/docker_1ch_s100x100.png"
    image = load_image_as_array(path)

    ga = GeneticAlgorithm(
        image, population_size=500, elite_rate=0.3, mutation_pop_rate=0.05, mutation_arr_rate=0.05, generations=500
    )
    pop = ga.run()

    # save the best individual as image
    best = pop[0].reshape(ga.image_shape).astype(float)
    best *= 255

    Image.fromarray(best).convert("RGB").save("data/output/best_individual.png")
