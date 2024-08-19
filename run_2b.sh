#!/bin/bash
# Script para el Ejercicio 2 Inciso b

# Nombre del archivo de código
BEST_FILE="piSeriesNaiveV4.c"

# Compilar la versión sin optimización
echo "Compilando sin optimización..."
gcc -fopenmp -o pi_parallel_v4 $BEST_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error al compilar $BEST_FILE sin optimización"
    exit 1
fi

# Compilar la versión con optimización -O2
echo "Compilando con optimización -O2..."
gcc -fopenmp -O2 -o pi_parallel_v4_optimized $BEST_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error al compilar $BEST_FILE con optimización -O2"
    exit 1
fi

# Parámetros de prueba
n=10000000
threads=4
num_measurements=5

# Función para calcular el promedio de tiempo
function calculate_average() {
    local sum=0.0
    local count=$#
    for time in "$@"; do
        sum=$(echo "$sum + $time" | bc -l)
    done
    echo "scale=6; $sum / $count" | bc -l
}

# Ejecutar pruebas sin optimización
times_no_opt=()
echo "==================================="
echo "| Ejecución sin optimización       |"
echo "==================================="
for ((i = 0; i < num_measurements; i++)); do
    start_time=$(date +%s.%N)
    OMP_NUM_THREADS=$threads ./pi_parallel_v4 $n $threads > /dev/null 2>&1
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc -l)
    times_no_opt+=($elapsed_time)
done

avg_time_no_opt=$(calculate_average "${times_no_opt[@]}")
echo "Promedio de tiempo sin optimización: $avg_time_no_opt segundos"

# Ejecutar pruebas con optimización -O2
times_opt=()
echo "==================================="
echo "| Ejecución con optimización -O2   |"
echo "==================================="
for ((i = 0; i < num_measurements; i++)); do
    start_time=$(date +%s.%N)
    OMP_NUM_THREADS=$threads ./pi_parallel_v4_optimized $n $threads > /dev/null 2>&1
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc -l)
    times_opt+=($elapsed_time)
done

avg_time_opt=$(calculate_average "${times_opt[@]}")
echo "Promedio de tiempo con optimización -O2: $avg_time_opt segundos"

echo "Pruebas completadas."
