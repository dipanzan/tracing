#!/bin/bash

NUM_OF_TRHEADS=$1
FILE_SIZE=$2
NUM_OF_NETWORK_REQS=$3
TIME=$4
NUM_OF_RUNS=$5
ENABLE_RANDOM=$6

LTTNG_TRACE_DIR="/home/dipanzan/lttng/traces"

for ((i=0;i<$NUM_OF_RUNS;i++))
do
    TRACE_SESSION_NAME="time-${TIME}s-threads-$NUM_OF_TRHEADS-file-$FILE_SIZE-trace-$i-$ENABLE_RANDOM"

    lttng create $TRACE_SESSION_NAME --output=$LTTNG_TRACE_DIR
    #lttng enable-channel --kernel --num-subbuf=4 --subbuf-size=256M --session=$TRACE_SESSION_NAME temp-channel

    # enable all syscalls and events
    lttng enable-event --kernel --all
    lttng enable-event --kernel --syscall --all

    lttng start

    # apply load
    /home/dipanzan/lttng/load.sh $@
    
    #lttng disable-channel --kernel --session=$TRACE_SESSION_NAME temp-channel
    lttng destroy

    mv "$LTTNG_TRACE_DIR/kernel" "$LTTNG_TRACE_DIR/$TRACE_SESSION_NAME"
done

chown -R dipanzan:dipanzan $LTTNG_TRACE_DIR
