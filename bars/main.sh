#!/usr/bin/env bash
# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

DIR="${0%/*}/.."

# This is the conduit where subprocesses can comminucate to the main process.
# Doing cache:push will send updates upward via this pipe.
PIPE="/tmp/lemon.$$"
mkfifo "$PIPE"

# Cache of outputs (a map)
declare -A CACHE

# Cleanup crew
finish() {
  pkill -P $$
  rm -f "$PIPE"
}
trap finish EXIT

# Colors
HILITE="%{F-}%{U${ACCENT_COLOR:-#6C5CE7}}%{+u}" # highlight
RESET="%{F-}%{-u}" # reset
MUTE="%{F${MUTE_COLOR:-#80FFFFFF}}" # mute
SPACE="%{O16}"
SPACE2="%{O24}"

bar() {
  echo -en "%{l}${SPACE2}${CACHE[I3SPACES]}"
  echo -en "%{r}${CACHE[BATTERY]}${SPACE2}"
  echo -en "%{c}${CACHE[CLOCK]}"
}

cache:push() {
  echo "$1" "$2" > "$PIPE"
}

# Continuously render when `cache:push`
while read line <$PIPE; do
  key="$(echo "$line" | cut -d' ' -f1)"
  val="$(echo "$line" | cut -d' ' -f2-)"
  CACHE["$key"]="$val"
  output="$(bar)"
  if [[ "${CACHE[_output]}" != "$output" ]]; then
    echo "$output"
  fi
  CACHE[_output]="$output"
done &

# Load the modules
source "$DIR/modules/battery.sh"
source "$DIR/modules/clock.sh"
source "$DIR/modules/i3spaces.sh"

wait
