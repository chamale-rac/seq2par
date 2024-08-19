#!/bin/bash
# EXERCISE 1g

# Filenames for the sequential and parallel versions
SEQ_FILE="piSeriesSeq.c"
PARALLEL_FILE="piSeriesNaiveV3.c"

# Compile the sequential version
echo "gcc -o pi_seq $SEQ_FILE -lm"
gcc -o pi_seq $SEQ_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error compiling $SEQ_FILE"
    exit 1
fi

# Compile the parallel version with OpenMP support
echo "gcc -fopenmp -o pi_parallel $PARALLEL_FILE -lm"
gcc -fopenmp -o pi_parallel $PARALLEL_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error compiling $PARALLEL_FILE"
    exit 1
fi

# Get the number of cores in the system
cores=$(nproc)
echo "Detected $cores cores in the system."

# Set n to 10e6 for this exercise
n=10000000
num_measurements=5

# Function to calculate average time
function calculate_average() {
    local sum=0.0
    local count=$#
    for time in "$@"; do
        sum=$(echo "$sum + $time" | bc)
    done
    echo "scale=6; $sum / $count" | bc
}

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
    echo "Parallel time: $parallel_time seconds (average of $num_measurements measurements)"
    echo "Speedup: $speedup"
    echo "Efficiency: $efficiency"
    echo "------------------------------"
}

# Function to run tests and capture times
function run_test() {
    local n=$1
    local threads=$2
    local is_sequential=$3
    local times=()

    for ((i = 0; i < num_measurements; i++)); do
        if [ $is_sequential -eq 1 ]; then
            start_time=$(date +%s.%N)
            ./pi_seq $n > /dev/null 2>&1
            end_time=$(date +%s.%N)
        else
            start_time=$(date +%s.%N)
            OMP_NUM_THREADS=$threads ./pi_parallel $n $threads > /dev/null 2>&1
            end_time=$(date +%s.%N)
        fi
        elapsed_time=$(echo "$end_time - $start_time" | bc)
        times+=($elapsed_time)
    done

    # Calculate the average time
    avg_time=$(calculate_average "${times[@]}")
    echo $avg_time
}

# Sequential time (threads = 1)
echo "==================================="
echo "| Sequential version (threads = 1) |"
echo "==================================="
seq_time=$(run_test $n 1 1)
echo "Sequential time: $seq_time seconds (average of $num_measurements measurements)"

# Parallel time (threads = cores)
echo "==================================="
echo "| Parallel version (threads = cores) |"
echo "==================================="
parallel_time_cores=$(run_test $n $cores 0)
display_results $n $seq_time $parallel_time_cores $cores

# Parallel time (threads = 2 * cores)
echo "==================================="
echo "| Parallel version (threads = 2 * cores) |"
echo "==================================="
parallel_time_2cores=$(run_test $n $((2 * cores)) 0)
display_results $n $seq_time $parallel_time_2cores $((2 * cores))

# Parallel time (n = n * 10 && threads = cores)
n_large=$((n * 10))
echo "==================================="
echo "| Parallel version (n = n * 10, threads = cores) |"
echo "==================================="
parallel_time_nlarge=$(run_test $n_large $cores 0)
display_results $n_large $seq_time $parallel_time_nlarge $cores

echo "Finished running all tests."
