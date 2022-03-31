#!/bin/bash

NUM_OF_TRHEADS=$1
FILE_SIZE=$2
NUM_OF_NETWORK_REQS=$3
TIME=$4
NUM_OF_RUNS=$5
ENABLE_RANDOM=$6

NUM_OF_CPU_MAX_PRIMES=10000
NUM_OF_FILES=128
TOTAL_MEMORY_SIZE=100G
NUM_OF_MUTEX=4096

VERBOSITY_LEVEL=0

cpu() {
    echo "cpu load: $NUM_OF_CPU_MAX_PRIMES primes"
    sysbench --verbosity=0 --time=$TIME --threads=$NUM_OF_TRHEADS --test=cpu --cpu-max-prime=$NUM_OF_CPU_MAX_PRIMES run
}

memory() {
    echo "memory load: $TOTAL_MEMORY_SIZE"
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=memory --memory-access-mode=rnd --memory-total-size=$TOTAL_MEMORY_SIZE run
}

threads() {
    echo "thread load: $NUM_OF_TRHEADS threads"
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=threads run
}

mutex() {
    echo "mutex load: $NUM_OF_MUTEX mutexes"
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=mutex --mutex-num=$NUM_OF_MUTEX run
}

file() {
    echo "file load: $NUM_OF_FILES files with size $FILE_SIZE"
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=fileio --file-num=$NUM_OF_FILES --file-test-mode=rndrw --file-total-size=$FILE_SIZE prepare
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=fileio --file-num=$NUM_OF_FILES --file-test-mode=rndrw --file-total-size=$FILE_SIZE run
    sysbench --verbosity=$VERBOSITY_LEVEL --time=$TIME --threads=$NUM_OF_TRHEADS --test=fileio --file-num=$NUM_OF_FILES --file-test-mode=rndrw --file-total-size=$FILE_SIZE cleanup
}

network() {
    echo "network load: parallel $NUM_OF_NETWORK_REQS requests to www.google.com"
    for i in `seq 1 $NUM_OF_NETWORK_REQS`; do curl --parallel --silent -o /dev/null "www.google.com"; done
}

cpu_memory_threads_mutex() {
    cpu
    memory
    threads
    mutex
}

file_network() {
    file
    network
}

load() {
    if [[ "$ENABLE_RANDOM" == "r" ]]; then
        cpu_memory_threads_mutex
        random=$((RANDOM%2))
        if [ $random == 1 ]; then
            file_network
        fi
    else
        cpu_memory_threads_mutex
        file_network
    fi
}

load
