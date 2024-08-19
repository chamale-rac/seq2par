/*
 * Filename: piSeriesNaiveV4.c
 * Author: Samuel Chamalé, cha21881@uvg.edu.gt
 * Date: 08/18/2024
 * Description: This program calculates an approximation of PI using the Leibniz series.
 *              The calculation is parallelized using OpenMP. The number of threads,
 *              the number of terms in the series (n), the scheduling policy, and block size
 *              can be specified using environment variables.
 *
 * Compilation: gcc -fopenmp -o pi_parallel_v4 piSeriesNaiveV4.c -lm
 * Usage: OMP_NUM_THREADS=<threads> OMP_SCHEDULE=<schedule,block_size> ./pi_parallel_v4 <number_of_terms>
 * Example: OMP_NUM_THREADS=4 OMP_SCHEDULE="static,16" ./pi_parallel_v4 1000000
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    // Parse command-line arguments
    if (argc != 2) {
        printf("Usage: %s <number_of_terms>\n", argv[0]);
        return -1;
    }

    int n = atoi(argv[1]); // Number of terms
    double sum = 0.0;
    double factor; // Declare factor outside the loop to use it in private()

    // Parallel computation of PI approximation using OpenMP
    #pragma omp parallel for reduction(+:sum) private(factor) schedule(runtime)
    for (int k = 0; k < n; k++) {
        factor = (k % 2 == 0) ? 1.0 : -1.0; // Private variable for each thread
        sum += factor / (2 * k + 1);
    }

    // Multiply sum by 4 to get the final approximation of PI
    double pi_approx = 4.0 * sum;
    printf("%.15f\n", pi_approx);

    return 0;
}
