#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef unsigned char uint8_t;

// Function to read image from file
uint8_t* load_image_as_array(const char* filename, int* width, int* height) {
    // Code to read the image and convert it to array goes here
    // ...
    // Dummy implementation for demonstration purposes
    *width = 10;
    *height = 10;
    uint8_t* image = malloc((*width) * (*height) * sizeof(uint8_t));
    for (int i = 0; i < (*width) * (*height); i++) {
        image[i] = rand() % 2;
    }
    return image;
}

typedef struct {
    int* image;
    int image_width;
    int image_height;
    int* target;
    int target_size;
    int population_size;
    int generations;
    int elite_size;
    int mutation_size;
    int mutation_arr_size;
    int** population;
    float* score;
    float best_score;
} GeneticAlgorithm;

GeneticAlgorithm* create_genetic_algorithm(
    int* image,
    int image_width,
    int image_height,
    int population_size,
    float elite_rate,
    float mutation_pop_rate,
    float mutation_arr_rate,
    int generations
) {
    GeneticAlgorithm* ga = malloc(sizeof(GeneticAlgorithm));
    ga->image = image;
    ga->image_width = image_width;
    ga->image_height = image_height;
    ga->target_size = image_width * image_height;
    ga->target = malloc(ga->target_size * sizeof(int));
    ga->population_size = population_size;
    ga->generations = generations;
    ga->elite_size = (int)(population_size * elite_rate);
    ga->mutation_size = (int)(population_size * mutation_pop_rate);
    ga->mutation_arr_size = (int)(ga->target_size * mutation_arr_rate);
    ga->population = malloc(population_size * sizeof(int*));
    for (int i = 0; i < population_size; i++) {
        ga->population[i] = malloc(ga->target_size * sizeof(int));
    }
    ga->score = malloc(population_size * sizeof(float));
    ga->best_score = 0.0f;
    return ga;
}

void destroy_genetic_algorithm(GeneticAlgorithm* ga) {
    free(ga->target);
    for (int i = 0; i < ga->population_size; i++) {
        free(ga->population[i]);
    }
    free(ga->population);
    free(ga->score);
    free(ga);
}

void genesis(GeneticAlgorithm* ga) {
    srand(time(NULL));
    for (int i = 0; i < ga->target_size; i++) {
        ga->target[i] = (ga->image[i] > 0) ? 1 : 0;
    }
    for (int i = 0; i < ga->population_size; i++) {
        for (int j = 0; j < ga->target_size; j++) {
            ga->population[i][j] = rand() % 2;
        }
        ga->score[i] = __FLT_MAX__;
    }
}

void single_mutation(GeneticAlgorithm* ga, int* individual) {
    for (int i = 0; i < ga->mutation_arr_size; i++) {
        int index = rand() % ga->target_size;
        individual[index] = rand() % 2;
    }
}

void mutation(GeneticAlgorithm* ga) {
    for (int i = 0; i < ga->mutation_size; i++) {
        int index = rand() % ga->population_size;
        single_mutation(ga, ga->population[index]);
    }
}

void single_crossover(GeneticAlgorithm* ga, int* parent1, int** population, int* child) {
    int index = rand() % ga->target_size;
    int* parent2 = population[rand() % ga->population_size];
    for (int i = 0; i < index; i++) {
        child[i] = parent1[i];
    }
    for (int i = index; i < ga->target_size; i++) {
        child[i] = parent2[i];
    }
}

void per_item_all(GeneticAlgorithm* ga, int* parent1, int** population, int* child) {
    int* parent2 = population[rand() % ga->population_size];
    for (int i = 0; i < ga->target_size; i++) {
        child[i] = (parent1[i] == parent2[i]) ? parent1[i] : rand() % 2;
    }
}

void crossover(GeneticAlgorithm* ga) {
    for (int i = 0; i < ga->population_size - ga->elite_size; i++) {
        per_item_all(ga, ga->population[i], ga->population, ga->population[i]);
    }
}

void fitness(GeneticAlgorithm* ga) {
    for (int i = 0; i < ga->population_size; i++) {
        float sum = 0.0f;
        for (int j = 0; j < ga->target_size; j++) {
            float diff = (float)(ga->population[i][j] - ga->target[j]);
            sum += diff * diff;
        }
        ga->score[i] = sum / ga->target_size;
    }
}

void sort_population(GeneticAlgorithm* ga) {
    fitness(ga);
    for (int i = 0; i < ga->population_size - 1; i++) {
        for (int j = 0; j < ga->population_size - i - 1; j++) {
            if (ga->score[j] > ga->score[j + 1]) {
                float temp_score = ga->score[j];
                ga->score[j] = ga->score[j + 1];
                ga->score[j + 1] = temp_score;
                int* temp_individual = ga->population[j];
                ga->population[j] = ga->population[j + 1];
                ga->population[j + 1] = temp_individual;
            }
        }
    }
}

void run(GeneticAlgorithm* ga) {
    genesis(ga);
    int i;
    for (i = 1; i <= ga->generations; i++) {
        sort_population(ga);
        int** elite = malloc(ga->elite_size * sizeof(int*));
        for (int j = 0; j < ga->elite_size; j++) {
            elite[j] = ga->population[j];
        }
        crossover(ga);
        mutation(ga);
        int* new_population = malloc((ga->population_size - ga->elite_size) * sizeof(int*));
        for (int j = 0; j < ga->population_size - ga->elite_size; j++) {
            new_population[j] = ga->population[j + ga->elite_size];
        }
        free(ga->population);
        ga->population = malloc(ga->population_size * sizeof(int*));
        for (int j = 0; j < ga->elite_size; j++) {
            ga->population[j] = elite[j];
        }
        for (int j = ga->elite_size; j < ga->population_size; j++) {
            ga->population[j] = new_population[j - ga->elite_size];
        }
        free(elite);
        free(new_population);
        if (ga->score[0] < ga->best_score) {
            ga->best_score = ga->score[0];
            printf("Gen. %d: Best individual: %f\n", i, ga->best_score);
            if (ga->best_score == 0.0f) {
                break;
            }
        }
    }
    printf("Run Ended at Gen. %d: Best individual: %f\n", i, ga->best_score);
    sort_population(ga);
}

int main() {
    // Load image and convert it to array
    int width, height;
    uint8_t* image = load_image_as_array("image.jpg", &width, &height);

    // Create and run genetic algorithm
    int population_size = 100;
    float elite_rate = 0.1f;
    float mutation_pop_rate = 0.1f;
    float mutation_arr_rate = 0.1f;
    int generations = 100;
    GeneticAlgorithm* ga = create_genetic_algorithm(image, width, height, population_size, elite_rate, mutation_pop_rate, mutation_arr_rate, generations);
    run(ga);

    // Clean up
    destroy_genetic_algorithm(ga);
    free(image);

    return 0;
}
