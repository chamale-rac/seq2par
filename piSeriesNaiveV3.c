/*
 * Filename: piSeriesNaiveV3.c
 * Author: Samuel Chamalé, cha21881@uvg.edu.gt
 * Date: 08/18/2024
 * Description: This program calculates an approximation of PI using the Leibniz series.
 *              The calculation is parallelized using OpenMP. The number of threads and
 *              the number of terms in the series (n) can be specified as command-line
 *              arguments. This version eliminates the loop dependency by calculating
 *              the factor directly based on the value of k and ensures correct scope
 *              handling using the private() clause in OpenMP.
 *
 * Compilation: gcc -fopenmp -o pi_parallel_v3 piSeriesNaiveV3.c -lm
 * Usage: ./pi_parallel_v3 <number_of_terms> <number_of_threads>
 * Example: ./pi_parallel_v3 1000000 4
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    // Parse command-line arguments
    int n = atoi(argv[1]); // Number of terms
    int thread_count = atoi(argv[2]); // Number of threads

    double sum = 0.0;
    double factor; // Declare factor outside the loop to use it in private()

    // Parallel computation of PI approximation using OpenMP
    #pragma omp parallel for num_threads(thread_count) reduction(+:sum) private(factor)
    for (int k = 0; k < n; k++) {
        factor = (k % 2 == 0) ? 1.0 : -1.0; // Private variable for each thread
        sum += factor / (2 * k + 1);
    }

    // Multiply sum by 4 to get the final approximation of PI
    double pi_approx = 4.0 * sum;
    printf("%.15f\n", pi_approx);

    return 0;
}
