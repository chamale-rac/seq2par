#!/bin/bash
# Script para el Ejercicio 2 Inciso a

# Nombre del archivo de código
ALT_FILE="piSeriesAlt.c"

# Compilar el programa
echo "gcc -fopenmp -o pi_series_alt $ALT_FILE -lm"
gcc -fopenmp -o pi_series_alt $ALT_FILE -lm
if [ $? -ne 0 ]; then
    echo "Error al compilar $ALT_FILE"
    exit 1
fi

# Parámetros de prueba
n=10000000
threads=(2 4 8 16)
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

# Ejecutar pruebas y capturar tiempos
for t in "${threads[@]}"; do
    times=()
    echo "==================================="
    echo "| Ejecutando con $t hilos          |"
    echo "==================================="
    for ((i = 0; i < num_measurements; i++)); do
        start_time=$(date +%s.%N)
        OMP_NUM_THREADS=$t ./pi_series_alt $n $t > /dev/null 2>&1
        end_time=$(date +%s.%N)
        elapsed_time=$(echo "$end_time - $start_time" | bc -l)
        times+=($elapsed_time)
    done

    # Calcular el tiempo promedio
    avg_time=$(calculate_average "${times[@]}")
    echo "Promedio de tiempo con $t hilos: $avg_time segundos"
done

echo "Pruebas completadas."
