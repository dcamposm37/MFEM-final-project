#!/bin/bash
#El comando !/bin/bash indica que el script se ejecutará en bash
#Esto es esencial para scripts que utilizan características
#específicas de Bash que no están disponibles en otros shells
#como sh (Shell estándar de UNIX).

# Limpiar archivos de salida al comienzo

#> time.txt
#for thread in $THREADS; do
#    > time$thread.txt
#done

TARGET=ex1p
MAX_THREADS=64
THREADS=$(seq 8 $MAX_THREADS)
REPS=$(seq 1 10)
ORDER=10


# Loop para ejecutar comandos
for thread in $THREADS; do
    echo -e "Ejecucion para el thread: $thread\n"
    for Nreps in $REPS; do
        echo -e "Repeticion: $Nreps\n"
#        /usr/bin/time -f "%S" mpirun -np $thread --oversubscribe ./${TARGET} -o $ORDER > output$thread.txt 2>> time$thread.txt
	mpirun -np $thread --oversubscribe ./${TARGET} -o $ORDER > output$thread.txt 2>> time$thread.txt
    done
    # Calcular el promedio
    average=$(awk '{ sum += $1 } END { if (NR > 0) print sum / NR }' time$thread.txt)

    # Calcular la desviación estándar
    stdev=$(awk -v avg="$average" '{ sumsq += ($1 - avg)^2 } END { if (NR > 1) print sqrt(sumsq / (NR - 1)) }' time$thread.txt)

    # Guardar el promedio y la desviación estándar en time.txt
    echo "$thread $average $stdev" >> time.txt

   # Guardar la iteración y las últimas dos líneas de output$thread.txt en output.txt
    echo -e "Iteración con $thread thread(s):" >> output.txt
    tail -n 2 output$thread.txt >> output.txt
    echo -e "-------------------------------------------------------------------------" >> output.txt
done

T1=$(awk 'NR==1 {print $2}' time.txt)

awk '{print $1, '$T1'/$2, '$T1'/$2/$1}' time.txt > metrics.txt

python3 plot.py

#for ((i=1; i<=$MAX_THREADS; i++)); do
#    rm time${i}.txt output${i}.txt
#done

#rm mesh* sol*
