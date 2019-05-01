# Check 3rd-party dependencies
source "${DIR}/utils/check_deps.sh"

# Get screen width
WIDTH="$(i3-msg -t get_workspaces | "${DIR}/vendor/json.sh" -b | egrep '\[0,"rect","width"\]' | cut -f2)"

# Bar height
HEIGHT=40

# Padding on the left/right of the bar
PAD=16

# Colors
LINE_COLOR="#10FFFFFF"
MUTE_COLOR="#80FFFFFF"
TEXT_COLOR="#FFFFFFFF"
ACCENT_COLOR="#FC5C00"

# Position
POSITION=top

# Fonts
MAIN_FONT="Inter Medium-10"
XL_FONT="Inter Thin BETA-64"

# Export for scripts
export LINE_COLOR MUTE_COLOR TEXT_COLOR ACCENT_COLOR

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
  -f "Font Awesome 5 Free-Regular-10" \
  &
PIDS="$PIDS $!"

# Horizontal line
echo "" \
  | lemonbar \
  -g "$((WIDTH - PAD - PAD))x1+$((PAD))+$((HEIGHT - 1))"  \
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
  -b \
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
