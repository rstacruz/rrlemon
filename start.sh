#!/bin/sh

DIR="${0%/*}"
WIDTH=1920
HEIGHT=40
PAD=16
POSITION=top

finish() {
  pkill -P $$
}

trap finish EXIT

killall lemonbar &>/dev/null
killall polybar &>/dev/null

(
  "${DIR}/bars/main.sh" | \
    lemonbar \
      -g "${WIDTH}x${HEIGHT}" \
      -u 2 \
      $(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi) \
      -f "Inter Medium-10" \
      -f "Font Awesome 5 Free-Regular-10"
) &

(
  # Horizontal line
  "${DIR}/bars/null.sh" | \
    lemonbar \
    -g "$((WIDTH - PAD - PAD))x1+$((PAD))+$((HEIGHT))"  \
    -d \
    -B "#10FFFFFF"
) &

(
  "${DIR}/bars/backdrop.sh" | \
    lemonbar \
      -g "${WIDTH}x128" \
      -F '#80FFFFFF' \
      -d \
      -b \
      -f "Inter Thin BETA-42"
) &

wait
