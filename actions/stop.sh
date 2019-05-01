# Kill everything before we start
pkill lemonbar
pkill polybar
pgrep -f "rrlemon" | grep -v $$ | xargs kill &>/dev/null
while pgrep -u "$UID" -x lemonbar &>/dev/null; do sleep 0.02; done

