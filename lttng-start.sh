#!/bin/bash

LTTNG_TRACE_DIR="/home/dipanzan/lttng/traces"
TRACE_SESSION_NAME="my-kernel-session"

NUM_OF_RUNS=$5

lttng create $TRACE_SESSION_NAME --output=$LTTNG_TRACE_DIR

# enable all syscalls and events
lttng enable-event --kernel --all
lttng enable-event --kernel --syscall --all

lttng start

# apply load
/home/dipanzan/lttng/load.sh $@

lttng destroy

mv "$LTTNG_TRACE_DIR/kernel" "$LTTNG_TRACE_DIR/$TRACE_SESSION_NAME"

chown -R dipanzan:dipanzan $LTTNG_TRACE_DIR