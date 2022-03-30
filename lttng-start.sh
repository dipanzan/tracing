#!/bin/bash

NUM_OF_TRHEADS=$1
FILE_SIZE=$2
NUM_OF_NETWORK_REQS=$3
TIME=$4
NUM_OF_RUNS=$5

LTTNG_TRACE_DIR="/home/dipanzan/lttng/traces"


for ((i=0;i<$5;i++))
do
    TRACE_SESSION_NAME="time-$TIME-threads-$NUM_OF_TRHEADS-file-$FILE_SIZE-trace-$i"

    lttng create $TRACE_SESSION_NAME --output=$LTTNG_TRACE_DIR

    # enable all syscalls and events
    lttng enable-event --kernel --all
    lttng enable-event --kernel --syscall --all

    lttng start

    # apply load
    /home/dipanzan/lttng/load.sh $@

    lttng destroy

    mv "$LTTNG_TRACE_DIR/kernel" "$LTTNG_TRACE_DIR/$TRACE_SESSION_NAME"
done

chown -R dipanzan:dipanzan $LTTNG_TRACE_DIR
