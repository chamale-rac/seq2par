/*
 * Filename: piSeriesNaive.c
 * Author: Samuel Chamalé, cha21881@uvg.edu.gt
 * Date: 08/18/2024
 * Description: This program calculates an approximation of PI using the Leibniz series.
 *              The calculation is parallelized using OpenMP. The number of threads and
 *              the number of terms in the series (n) can be specified as command-line
 *              arguments.
 *
 * Compilation: gcc -fopenmp -o pi_parallel piSeriesNaive.c -lm
 * Usage: ./pi_parallel <number_of_terms> <number_of_threads>
 * Example: ./pi_parallel 1000000 4
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    // Check for the correct number of arguments, commented for avoid time waste
    // if (argc != 3) {
    //     printf("Usage: %s <number_of_terms> <number_of_threads>\n", argv[0]);
    //     return -1;
    // }

    // Parse command-line arguments
    int n = atoi(argv[1]); // Number of terms
    int thread_count = atoi(argv[2]); // Number of threads

    // Validate inputs, commented for avoid time waste
    // if (n <= 0 || thread_count <= 0) {
    //     printf("Error: number_of_terms and number_of_threads must be positive integers.\n");
    //     return -1;
    // }

    double sum = 0.0;

    // Parallel computation of PI approximation using OpenMP
    #pragma omp parallel for num_threads(thread_count) reduction(+:sum)
    for (int k = 0; k < n; k++) {
        double factor = (k % 2 == 0) ? 1.0 : -1.0;
        sum += factor / (2 * k + 1);
    }

    // Multiply sum by 4 to get the final approximation of PI
    double pi_approx = 4.0 * sum;
    printf("%.15f", pi_approx);

    return 0;
}
