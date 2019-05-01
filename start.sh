#!/usr/bin/env bash
set -m
DIR="${0%/*}"

# Check 3rd-party dependencies
source "${DIR}/utils/check_deps.sh"

# Get screen width
WIDTH="$(i3-msg -t get_workspaces | jq '.[] | select(.focused).rect.width')"

# Bar height
HEIGHT=40

# Padding on the left/right of the bar
PAD=16

# Colors
LINE_COLOR="#10FFFFFF"
MUTE_COLOR="#80FFFFFF"
TEXT_COLOR="#FFFFFFFF"
ACCENT_COLOR="#FC5C00"

# Position
POSITION=top

# Fonts
MAIN_FONT="Inter Medium-10"
XL_FONT="Inter Thin BETA-64"

export LINE_COLOR MUTE_COLOR TEXT_COLOR ACCENT_COLOR

# Cleanup crew
finish() {
  pkill -P $$
  killall "$(basename "$0")" &>/dev/null
}
trap finish EXIT
trap finish SIGHUP
trap finish SIGINT
trap finish SIGTERM

# Kill everything before we start
killall lemonbar &>/dev/null
killall polybar &>/dev/null
while pgrep -u "$UID" -x lemonbar &>/dev/null; do sleep 0.02; done

"${DIR}/bars/main.sh" \
  | lemonbar \
  -g "${WIDTH}x${HEIGHT}" \
  "$(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi)" \
  -F "$TEXT_COLOR" \
  -f "$MAIN_FONT" \
  -f "Font Awesome 5 Free-Regular-10" \
  &

# Horizontal line
"${DIR}/bars/null.sh" \
  | lemonbar \
  -g "$((WIDTH - PAD - PAD))x1+$((PAD))+$((HEIGHT))"  \
  -d \
  -B "$LINE_COLOR" \
  &

  "${DIR}/bars/backdrop.sh" \
    | lemonbar \
    -g "${WIDTH}x128" \
    -n 'bar-backdrop' \
    -F "$MUTE_COLOR" \
    -d \
    -b \
    -f "$XL_FONT" \
    &

while ! xdo id -a "bar-backdrop" &>/dev/null; do sleep 0.1; done
xdo id -a "bar-backdrop" | while read id; do
  xdo lower "$id"
done

wait
