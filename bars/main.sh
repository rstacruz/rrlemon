#!/usr/bin/env bash
# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

set -eo pipefail
DIR="${0%/*}/.."

# This is the conduit where subprocesses can comminucate to the main process.
# Doing cache:push will send updates upward via this pipe.
PIPE="/tmp/lemon.$$"
mkfifo "$PIPE"

# Cache of outputs (a map)
declare -A CACHE

# Cleanup crew
PIDS=""
finish() {
  rm -f "$PIPE"
}
trap finish EXIT SIGHUP SIGINT SIGTERM

# Colors
HILITE="%{F-}%{U${ACCENT_COLOR:-#6C5CE7}}%{+u}" # highlight
RESET="%{F-}%{-u}" # reset
MUTE="%{F${MUTE_COLOR:-#80FFFFFF}}" # mute
SPACE="%{O${SPACE_WIDTH}}"
SPACE2="%{O${SPACE_2_WIDTH}}"
MODULES="${MODULES:-mid}"

bar() {
  local __="${SPACE2}"
  local _="${SPACE}"
  if [[ "${CACHE[I3LOCK]}" == "Locked" ]]; then
    echo -en "%{c}This workstation is locked."
    echo -en "%{r}${MUTE}${CACHE[CLOCK]}$__"
  elif [[ "$MODULES" == "lr" ]]; then
    # left/right
    echo -en "%{l}$__${CACHE[I3SPACES]}"
    echo -en "%{r}${CACHE[BATTERY]}$__${RESET}${CACHE[CLOCK]}$__"
  elif [[ "$MODULES" == "mid" ]]; then
    # mid (middle window title)
    echo -en "%{l}$__${CACHE[I3SPACES]}"
    echo -en "%{r}${CACHE[BATTERY]}$__${RESET}${CACHE[CLOCK]}$__"
    echo -en "%{c}${RESET}${CACHE[I3WINDOW]}"
  else
    # midclock
    echo -en "%{l}$__${CACHE[I3SPACES]}"
    echo -en "%{r}${CACHE[BATTERY]}$__"
    echo -en "%{c}${RESET}${CACHE[CLOCK]}"
  fi
  # echo -en "%{l}${SPACE2}${CACHE[I3SPACES]}"
  # echo -en "%{r}${CACHE[BATTERY]}${SPACE}${CACHE[CLOCK]}${SPACE2}"
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
PIDS="$PIDS $!"

# Load the modules
source "$DIR/modules/battery.sh" & PIDS="$PIDS $!"
source "$DIR/modules/clock.sh" & PIDS="$PIDS $!"
source "$DIR/modules/i3spaces.sh" & PIDS="$PIDS $!"
source "$DIR/modules/i3window.sh" & PIDS="$PIDS $!"
source "$DIR/modules/i3lock.sh" & PIDS="$PIDS $!"

wait $PIDS
