/*
 * Filename: piSeriesSeq.c
 * Author: Samuel Chamalé, cha21881@uvg.edu.gt
 * Date: 08/18/2024
 * Description: This program calculates an approximation of PI using the Leibniz series.
 *              The calculation is done sequentially. The number of terms in the series (n)
 *              can be specified as a command-line argument.
 *
 * Compilation: gcc -o pi_seq piSeriesSeq.c -lm
 * Usage: ./pi_seq <number_of_terms>
 * Example: ./pi_seq 1000000
 */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    // Check for the correct number of arguments, commented for avoid time waste
    // if (argc != 2) {
    //     printf("Usage: %s <number_of_terms>\n", argv[0]);
    //     return -1;
    // }

    // Parse command-line argument
    int n = atoi(argv[1]); // Number of terms

    // Validate input, commented for avoid time waste
    // if (n <= 0) {
    //     printf("Error: number_of_terms must be a positive integer.\n");
    //     return -1;
    // }

    double factor = 1.0;
    double sum = 0.0;

    // Sequential computation of PI approximation
    for (int k = 0; k < n; k++) {
        sum += factor / (2 * k + 1);
        factor = -factor; // Alternate between 1.0 and -1.0
    }

    // Multiply sum by 4 to get the final approximation of PI
    double pi_approx = 4.0 * sum;
    printf("%.15f", pi_approx);

    return 0;
}
