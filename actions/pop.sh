#!/usr/bin/env bash

# Check 3rd-party dependencies
DIR="${0%/*}/.."
source "${DIR}/utils/check_deps.sh"

# Get screen width
WIDTH="$(i3-msg -t get_workspaces | "${DIR}/vendor/json.sh" -b | egrep '\[0,"rect","width"\]' | cut -f2)"

# Bar height
HEIGHT=40

# Padding on the left/right of the bar
PAD=16

# Colors
LINE_COLOR="#10FFFFFF"
MUTE_COLOR="#A0DDEEFF"
TEXT_COLOR="#FFFFFFFF"
ACCENT_COLOR="#FC5C00"

# Position
POSITION=top

# Fonts
MAIN_FONT="Inter Medium-10"
XL_FONT="Inter Thin BETA-64"

# Export for scripts
export LINE_COLOR MUTE_COLOR TEXT_COLOR ACCENT_COLOR

# Cleanup crew
PIDS=""
finish() {
  pkill -P $$
}
trap finish EXIT
trap finish SIGHUP
trap finish SIGINT
trap finish SIGTERM

# Lol
echo "%{c}All systems online" \
  | lemonbar \
  -g "${WIDTH}x224" \
  -n 'bar-backdrop' \
  -F "$TEXT_COLOR" \
  -d \
  -b \
  -p \
  -f "$XL_FONT" \
  &
PIDS="$PIDS $!"

(
  sleep 1
  kill $PIDS
) &
PIDS="$PIDS $!"

# Wait for those pids
wait $PIDS
