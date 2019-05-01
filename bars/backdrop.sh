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

while true; do
  echo "%{r}$(clock)%{O32}"
  sleep 1
done
