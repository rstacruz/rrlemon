# Check 3rd-party dependencies
source "${DIR}/utils/check_deps.sh"
source "${DIR}/config.sh"

if [[ -f "${DIR}/config.local.sh" ]]; then
  source "${DIR}/config.local.sh"
fi

# Get screen width
WIDTH="$(i3-msg -t get_workspaces | "${DIR}/vendor/json.sh" -b | egrep '\[0,"rect","width"\]' | cut -f2)"

# Export for scripts
export \
  LINE_COLOR MUTE_COLOR TEXT_COLOR ACCENT_COLOR POSITION MAIN_FONT XL_FONT BACKGROUND_COLOR \
  SPACE_WIDTH SPACE_2_WIDTH

# Cleanup crew
PIDS=""
finish() {
  pkill -P $$
}
trap finish EXIT
trap finish SIGHUP
trap finish SIGINT
trap finish SIGTERM

"${DIR}/bars/main.sh" \
  | lemonbar \
  -g "${WIDTH}x${HEIGHT}" \
  "$(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi)" \
  -F "$TEXT_COLOR" \
  -f "$MAIN_FONT" \
  -B "$BACKGROUND_COLOR" \
  -f "Font Awesome 5 Free-Regular-10" \
  &
PIDS="$PIDS $!"

if [[ "$POSITION" == "top" ]]; then
  LINE_POSITION="$((PAD))+$((HEIGHT - 1))"
else
  LINE_POSITION="$((PAD))-$((HEIGHT - 1))"
fi

# Horizontal line
echo "" \
  | lemonbar \
  -g "$((WIDTH - PAD - PAD))x1+$LINE_POSITION"  \
  -n 'bar-backdrop' \
  -d \
  -p \
  -B "$LINE_COLOR" \
  &
PIDS="$PIDS $!"

# Backdrop
"${DIR}/bars/backdrop.sh" \
  | lemonbar \
  -g "${WIDTH}x128" \
  -n 'bar-backdrop' \
  -F "$MUTE_COLOR" \
  -d \
  "$(if [[ "$POSITION" == "top" ]]; then echo -ne "-b"; fi)" \
  -f "$XL_FONT" \
  &
PIDS="$PIDS $!"

# Lower the backdrop below all windows
while ! xdo id -a "bar-backdrop" &>/dev/null; do sleep 0.1; done
xdo id -a "bar-backdrop" | while read id; do
  xdo lower "$id"
done

# Wait for those pids
wait $PIDS
