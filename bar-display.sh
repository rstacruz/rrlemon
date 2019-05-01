#!/bin/sh

# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right
# %{F#000000}

c_text() {
  echo -ne "%{F-}"
  echo -ne "%{U#FFFFFFFF}"
}
c_mute() {
  echo -ne "%{F#80FFFFFF}"
}

C=$(c_text) # text
M=$(c_mute) # mute
S="    "    # space

clock() {
  local date="$(date "+%I:%M %p")"
  echo "$C$date"
}

battery() {
  # 85%
  local percent="$(cat /sys/class/power_supply/BAT0/capacity)%"

  # Discharging
  local status="$(cat /sys/class/power_supply/BAT0/status)"

  # "Battery 0: Discharging, 86%, 03:18:06 remaining"
  local batinfo="$( \
    acpi --battery \
      | grep 'Battery 0' \
      | head -n 1 \
  )"

  # 03:14:28
  local time="$(echo "$batinfo" | cut -d' ' -f5)"

  local suffix="$(if [[ "$status" == "Discharging" ]]; then echo "left"; else echo "to full"; fi)"

  echo -ne "$C$percent$M$S$time $suffix"
}

edgespace() {
  echo -ne "    "
}

bar() {
  echo -en "%{l}$(edgespace)$(battery)"
  echo -en "%{c}$(clock)"
}

while true; do
  echo "$(bar)"
  sleep 1
done

