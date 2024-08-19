#!/bin/bash
# EXERCISE 1h: Scheduling policies and block sizes

PARALLEL_FILE="piSeriesNaiveV4.c"

# Compile the parallel version with OpenMP support
echo "gcc -fopenmp -o pi_parallel_v4 $PARALLEL_FILE -lm"
gcc -fopenmp -o pi_parallel_v4 $PARALLEL_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error compiling $PARALLEL_FILE"
    exit 1
fi

# Set n to 10e6 for this exercise
n=10000000
num_measurements=5
threads=$(nproc)

# Schedules to test
schedules=("static" "dynamic" "guided")
block_sizes=(16 64 128)

# Function to calculate average time
function calculate_average() {
    local sum=0.0
    local count=$#
    for time in "$@"; do
        sum=$(echo "$sum + $time" | bc -l)
    done
    echo "scale=6; $sum / $count" | bc -l
}

# Function to format and display the results
function display_results() {
    local schedule=$1
    local block_size=$2
    local avg_time=$3

    echo "Scheduling: $schedule, Block Size: $block_size, Average Time: $avg_time seconds"
    echo "------------------------------"
}

# Function to run tests and capture times
function run_test() {
    local schedule=$1
    local block_size=$2
    local times=()

    for ((i = 0; i < num_measurements; i++)); do
        start_time=$(date +%s.%N)
        OMP_SCHEDULE="$schedule,$block_size" OMP_NUM_THREADS=$threads ./pi_parallel_v4 $n > /dev/null 2>&1
        end_time=$(date +%s.%N)
        elapsed_time=$(echo "$end_time - $start_time" | bc -l)
        times+=($elapsed_time)
    done

    # Calculate the average time
    avg_time=$(calculate_average "${times[@]}")
    display_results $schedule $block_size $avg_time
}

# Test each scheduling policy with different block sizes
echo "==================================="
echo "| Scheduling Tests                |"
echo "==================================="

# Test static, dynamic, and guided with different block sizes
for schedule in "${schedules[@]}"; do
    for block_size in "${block_sizes[@]}"; do
        run_test $schedule $block_size
    done
done

# Test auto scheduling (no block size)
echo "==================================="
echo "| Auto Scheduling Test            |"
echo "==================================="
times_auto=()
for ((i = 0; i < num_measurements; i++)); do
    start_time=$(date +%s.%N)
    OMP_SCHEDULE="auto" OMP_NUM_THREADS=$threads ./pi_parallel_v4 $n > /dev/null 2>&1
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc -l)
    times_auto+=($elapsed_time)
done

avg_time_auto=$(calculate_average "${times_auto[@]}")
echo "Scheduling: auto, Average Time: $avg_time_auto seconds"
echo "------------------------------"

echo "Finished running all tests."
