#!/bin/bash
# EXERCISE 1d

# Filenames for the sequential and parallel versions
SEQ_FILE="piSeriesSeq.c"
PARALLEL_FILE="piSeriesNaiveV2.c"

echo "gcc -o pi_seq $SEQ_FILE -lm"
gcc -o pi_seq $SEQ_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error compiling $SEQ_FILE"
    exit 1
fi

echo "gcc -fopenmp -o pi_parallel $PARALLEL_FILE -lm"
gcc -fopenmp -o pi_parallel $PARALLEL_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error compiling $PARALLEL_FILE"
    exit 1
fi

# Array of n values (starting from 1000 and increasing)
n_values=(1000 10000 100000 1000000 10000000)

# Array of thread counts (all >= 2)
thread_counts=(2 4 8 16 32)

# Function to format and display the results
function display_results() {
    local n=$1
    local seq_time=$2
    local parallel_time=$3
    local threads=$4

    # Calculate speedup and efficiency
    local speedup=$(echo "$seq_time / $parallel_time" | bc -l)
    local efficiency=$(echo "$speedup / $threads" | bc -l)

    # Display the results
    echo " => n = $n, threads = $threads"
    echo "Sequential time: $seq_time seconds"
    echo "Parallel time: $parallel_time seconds"
    echo "Speedup: $speedup"
    echo "Efficiency: $efficiency"
    echo "------------------------------"
}

# Run the sequential version and capture the execution time
echo "==================================="
echo "| Sequential version...           |"
echo "==================================="
for n in "${n_values[@]}"; do
    start_time=$(date +%s.%N)
    ./pi_seq $n
    end_time=$(date +%s.%N)
    seq_time=$(echo "$end_time - $start_time" | bc)
    echo " => n=$n: $seq_time seconds"
done

# Run the parallel version with different thread counts and capture the execution time
echo "==================================="
echo "| Parallel version...     |"
echo "==================================="
for i in "${!n_values[@]}"; do
    n=${n_values[$i]}
    threads=${thread_counts[$i]}

    # Measure time for parallel version
    start_time=$(date +%s.%N)
    OMP_NUM_THREADS=$threads ./pi_parallel $n $threads
    end_time=$(date +%s.%N)
    parallel_time=$(echo "$end_time - $start_time" | bc)

    # Retrieve sequential time for the same n
    seq_time=$(echo "$seq_time")

    # Display and store results
    display_results $n $seq_time $parallel_time $threads
done

echo "Finished running all tests."
