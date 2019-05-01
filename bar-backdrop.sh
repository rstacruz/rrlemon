#!/bin/sh

clock() {
  local date="$(date "+%I:%M")"
  echo "$date"
}

while true; do
  echo "%{r}$(clock)   "
  sleep 1
done
