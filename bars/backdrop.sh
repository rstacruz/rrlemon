#!/bin/sh

clock() {
  local date="$(date "+%I:%M" | sed 's/^0//')"
  echo "$date"
}

while true; do
  echo "%{r}$(clock)%{O32}"
  sleep 1
done
