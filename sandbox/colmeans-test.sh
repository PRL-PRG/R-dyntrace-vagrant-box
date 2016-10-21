#!/usr/local/bin/bash -x
set -e

R_HOME=R-dyntrace

if [ $EUID -ne 0 ]; then
    echo "This script should be run using sudo or as the root user"
    exit 1
fi

function do_expr {
  DTRACE_CMD="$1"
  OUTPUT="$2"
  echo $DTRACE_CMD

  export R_HOME=$R_HOME
  export LD_LIBRARY_PATH=$R_HOME/lib

  echo "Killing all running dtrace"
  pkill -9 dtrace || true

  for i in $(seq 1 $N); do
    $DTRACE_CMD > "$OUTPUT" &
    DTRACE_PID=$!

    until grep -q "Tracing" "$OUTPUT"; do
      sleep 1
    done

    $R_HOME/src/main/R.bin --vanilla --quiet --slave < "colmeans-test.R"

    kill $DTRACE_PID
    wait $DTRACE_PID
  done
}

do_expr "$R_HOME/share/dtrace/calltime.dtrace \"compute\"" calltime-compute.out
do_expr "$R_HOME/share/dtrace/calltime-all.dtrace" calltime-all.out
do_expr "$R_HOME/share/dtrace/flowinfo.dtrace" flowinfo.out
