/*
 * Filename: piSeriesAlt.c
 * Author: Samuel Chamalé, cha21881@uvg.edu.gt
 * Date: 08/18/2024
 * Description: This program calculates an approximation of PI using an alternative approach
 *              where the series is divided into two separate sums: one for even indices and
 *              another for odd indices. The number of threads and terms (n) can be specified.
 *
 * Compilation: gcc -fopenmp -o pi_series_alt piSeriesAlt.c -lm
 * Usage: ./pi_series_alt <number_of_terms> <number_of_threads>
 * Example: ./pi_series_alt 10000000 4
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    // Parse command-line arguments
    if (argc != 3) {
        printf("Usage: %s <number_of_terms> <number_of_threads>\n", argv[0]);
        return -1;
    }

    int n = atoi(argv[1]);         // Number of terms
    int thread_count = atoi(argv[2]); // Number of threads

    double sum_even = 0.0;
    double sum_odd = 0.0;

    // Parallel computation of the sums for even and odd indices
    #pragma omp parallel for num_threads(thread_count) reduction(+:sum_even)
    for (int i = 0; i < n; i += 2) {
        sum_even += 1.0 / (2 * i + 1);
    }

    #pragma omp parallel for num_threads(thread_count) reduction(+:sum_odd)
    for (int j = 1; j < n; j += 2) {
        sum_odd += 1.0 / (2 * j + 1);
    }

    // Combine the sums to calculate the final approximation of PI
    double pi_approx = 4.0 * (sum_even - sum_odd);
    printf("%.15f\n", pi_approx);

    return 0;
}
