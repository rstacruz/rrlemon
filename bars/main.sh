#!/usr/bin/env bash
# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

DIR="${0%/*}"

# Named pipes
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
HILITE="%{F-}%{U#6C5CE7}%{+u}" # highlight
RESET="%{F-}%{-u}" # reset
MUTE="%{F#80FFFFFF}" # mute
SPACE="%{O16}"
SPACE2="%{O24}"

# Color aliases
H="$HILITE"
R="$RESET"
C="$RESET"
M="$MUTE"
S="$SPACE"
SS="$SPACE2"

# Modules
source "$DIR/../modules/battery.sh"
source "$DIR/../modules/i3spaces.sh"

clock() {
  local date="$(date "+%I:%M %p" | sed 's/^0//')"
  echo "$C$date"
}

bar() {
  echo -en "%{l}${SS}${CACHE[I3SPACES]}"
  echo -en "%{r}${CACHE[BATTERY]}$SS"
  echo -en "%{c}${CACHE[CLOCK]}"
}

render() {
  echo "$(bar)"
}

cache:push() {
  echo "$1" "$2" > "$PIPE"
}

i3-msg -t subscribe -m '[ "workspace" ]' | while read output; do
  cache:push I3SPACES "$(i3spaces)"
done &

while true; do
  cache:push BATTERY "$(battery)"
  sleep 2.5
done &

while true; do
  cache:push CLOCK "$(clock)"
  sleep 1
done &

while read line <$PIPE; do
  key="$(echo "$line" | cut -d' ' -f1)"
  val="$(echo "$line" | cut -d' ' -f2-)"
  echo "setting $key to $val" >&2
  CACHE["$key"]="$val"
  render
done

render
wait
