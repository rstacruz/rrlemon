#!/bin/sh

if ! command -v i3-msg &>/dev/null; then
  echo 'i3-msg not found'
  exit 1
fi
if ! command -v jq &>/dev/null; then
  echo 'jq not found'
  exit 1
fi
if ! command -v acpi &>/dev/null; then
  echo 'acpi not found'
  exit 1
fi

DIR="${0%/*}"
WIDTH="$(i3-msg -t get_workspaces | jq '.[1].rect.width')"
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
