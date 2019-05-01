clock() {
  local date="$(date "+%I:%M %p" | sed 's/^0//')"
  echo "$RESET$date"
}

while true; do
  cache:push CLOCK "$(clock)"
  sleep 5
done
