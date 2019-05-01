#!/bin/sh

WIDTH=1920
HEIGHT=40
PAD=16
POSITION=top

# lemonbar-xft-git

killall lemonbar &>/dev/null
killall polybar &>/dev/null

(
  ./bar-display.sh | \
    lemonbar \
      -g "${WIDTH}x${HEIGHT}" \
      -u 2 \
      $(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi) \
      -f "Inter Medium-10" \
      -f "Font Awesome 5 Free-Regular-10"
) &

(
  # Horizontal line
  lemonbar \
    -g "$((WIDTH - PAD - PAD))x1+$((PAD))+$((HEIGHT))"  \
    -d \
    -B "#10FFFFFF"
) &

(
  ./bar-backdrop.sh | \
    lemonbar \
      -g "${WIDTH}x128" \
      -F '#80FFFFFF' \
      -d \
      -b \
      -f "Inter Thin BETA-42"
) &
