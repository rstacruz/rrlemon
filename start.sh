#!/bin/sh
DIR="${0%/*}"

# Check 3rd-party dependencies
source "${DIR}/utils/check_deps.sh"

# Get screen width
WIDTH="$(i3-msg -t get_workspaces | jq '.[] | select(.focused).rect.width')"

# Bar height
HEIGHT=40

# Padding on the left/right of the bar
PAD=16

POSITION=top

finish() {
  pkill -P $$
  killall "$(basename "$0")" &>/dev/null
}

trap finish EXIT

killall lemonbar &>/dev/null
killall polybar &>/dev/null

(
  "${DIR}/bars/main.sh" | \
    lemonbar \
      -g "${WIDTH}x${HEIGHT}" \
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
      -n 'bar-backdrop' \
      -F '#80FFFFFF' \
      -d \
      -b \
      -f "Inter Thin BETA-64"
) &

(
  while ! xdo id -a "bar-backdrop" &>/dev/null; do sleep 0.1; done
  xdo id -a "bar-backdrop" | while read id; do
    xdo lower "$id"
  done
) &

wait
