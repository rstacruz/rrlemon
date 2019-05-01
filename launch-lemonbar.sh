#!/bin/sh

HEIGHT=40
POSITION=bottom

# lemonbar-xft-git

./bar-display.sh | \
  lemonbar \
    -g 1920x$HEIGHT \
    -u 2 \
    $(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi) \
    -f "Inter Medium-10" \
    -f "Font Awesome 5 Free-Regular-10" \
    $*
