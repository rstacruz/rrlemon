#!/bin/sh
set -eo pipefail
finish() {
  pkill -P $$
  # Kill grand-descendant processes. Kills the lingering i3-msg
  for subpid in pgrep -P $$; do pkill "$subpid"; done
}
trap finish EXIT
trap finish SIGHUP
trap finish SIGINT
trap finish SIGTERM

clock() {
  local date="$(date "+%I:%M" | sed 's/^0//')"
  echo "$date"
}

position() {
  case "$1" in
    left)
      echo -ne "%{l}"
      ;;
    center)
      echo -ne "%{c}"
      ;;
    *)
      echo -ne "%{r}"
      ;;
  esac
}

while true; do
  pos="$(position ${BACKDROP_POSITION_X:-right})"
  echo "$pos%{O32}$(clock)%{O32}"
  sleep 10
done
