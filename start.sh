#!/bin/sh

WIDTH=1920
HEIGHT=40
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
      -f "Font Awesome 5 Free-Regular-10" \
      $*
) &

(
  ./bar-backdrop.sh | \
    lemonbar \
      -g "${WIDTH}x128" \
      -d \
      -b \
      -f "Inter Thin BETA-42"
) &
