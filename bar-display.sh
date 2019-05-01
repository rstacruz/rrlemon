#!/bin/sh

# https://wiki.archlinux.org/index.php/Lemonbar#Configuration
# %{l} %{c} %{r} - left, center, right

clock() {
  date "+%H:%M %p"
}

battery() {
  # cat /sys/class/power_supply/BAT0/capacity
  acpi --battery \
    | grep "Battery 0" \
    | cut -d':' -f1- \
    | head -n 1
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

