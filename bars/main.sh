#!/usr/bin/env bash
# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

DIR="${0%/*}"
I3SPACES=loading
BATTERY=loading

finish() {
  pkill -P $$
}

trap finish EXIT

c_text() {
  echo -ne "%{F-}"
  echo -ne "%{U#FFFFFFFF}"
}

c_mute() {
  echo -ne "%{F#80FFFFFF}"
}

C=$(c_text)    # text
M=$(c_mute)    # mute
S="    "       # space
SS="      "    # superspace

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
