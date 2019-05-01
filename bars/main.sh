#!/usr/bin/env bash
# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

DIR="${0%/*}"

finish() {
  pkill -P $$
}

trap finish EXIT

c_text() {
  echo -ne "%{F-}"
}

c_hilight() {
  echo -ne "%{F-}"
}

c_mute() {
  echo -ne "%{F#80FFFFFF}"
}

HILITE="%{F-}%{U#6C5CE7}%{+u}" # highlight
RESET="%{F-}%{-u}" # reset
MUTE="%{F#80FFFFFF}" # mute
SPACE="%{O16}"
SPACE2="%{O24}"

H="$HILITE"
R="$RESET"
C="$RESET"
M="$MUTE"
S="$SPACE"
SS="$SPACE2"

clock() {
  local date="$(date "+%I:%M %p" | sed 's/^0//')"
  echo "$C$date"
}

source "$DIR/../modules/battery.sh"
source "$DIR/../modules/i3spaces.sh"

edgespace() {
  echo -ne "    "
}

bar() {
  echo -en "%{l}$(edgespace)$(i3spaces)"
  echo -en "%{r}$(battery)$(edgespace)"
  echo -en "%{c}$(clock)"
}

bar:lr() {
  echo -en "%{l}$(edgespace)$(clock)$SS$(i3spaces)"
  echo -en "%{r}$(battery)$(edgespace)"
}

render() {
  echo "$(bar)"
}

{
  i3-msg -t subscribe -m '[ "workspace" ]' | while read output; do
    render
  done
} &

{
  while true; do
    render
    sleep 5
  done
} &

render
wait
