# Check 3rd-party dependencies
source "${DIR}/utils/check_deps.sh"
source "${DIR}/config.sh"

if [[ -f "${DIR}/config.local.sh" ]]; then
  source "${DIR}/config.local.sh"
fi

# Get screen dimensions
# (This is slow, and can be optimized!)
WORKSPACES_JSON="$(i3-msg -t get_workspaces | "${DIR}/vendor/json.sh" -b)"
SCREEN_WIDTH="$( echo "$WORKSPACES_JSON" | egrep '\[0,"rect","width"\]' | cut -f2)"
SCREEN_HEIGHT="$(echo "$WORKSPACES_JSON" | egrep '\[0,"rect","height"\]' | cut -f2)"

# Export for scripts
export \
  LINE_COLOR MUTE_COLOR TEXT_COLOR ACCENT_COLOR POSITION MAIN_FONT XL_FONT BACKGROUND_COLOR \
  LINE_PAD \
  TEXT_OFFSET \
  SPACE_WIDTH SPACE_2_WIDTH \
  BACKDROP_ENABLED BACKDROP_HEIGHT \
  BACKDROP_POSITION_X BACKDROP_POSITION_Y \
  BACKDROP_TEXT_COLOR \
  MODULES

# Cleanup crew
PIDS=""

if [[ "$POSITION" == "top" ]]; then
  LINE_POSITION="$((LINE_PAD))+$((HEIGHT - 1))"
else
  LINE_POSITION="$((LINE_PAD))+$((SCREEN_HEIGHT - HEIGHT))"
fi

# Horizontal line
echo "" \
  | lemonbar \
  -g "$((SCREEN_WIDTH - LINE_PAD - LINE_PAD))x1+$LINE_POSITION"  \
  -n 'bar-backdrop' \
  -d \
  -p \
  -B "$LINE_COLOR" \
  &
PIDS="$PIDS $!"

# Backdrop
if [[ "$BACKDROP_ENABLED" != "0" ]]; then

  if [[ "$POSITION" == "top" ]]; then
    if [[ "$BACKDROP_POSITION_Y" == "top" ]]; then
      Y="$((HEIGHT))"
    else # bottom
      Y="$((SCREEN_HEIGHT - BACKDROP_HEIGHT))"
    fi
  else # bottom
    if [[ "$BACKDROP_POSITION_Y" == "top" ]]; then
      Y="0"
    else
      Y="$((SCREEN_HEIGHT - HEIGHT - BACKDROP_HEIGHT))"
    fi
  fi

  "${DIR}/bars/backdrop.sh" \
    | lemonbar \
    -g "${SCREEN_WIDTH}x${BACKDROP_HEIGHT}+0+$Y" \
    -n 'bar-backdrop' \
    -F "$BACKDROP_TEXT_COLOR" \
    -d \
    -f "$XL_FONT" \
    &
  PIDS="$PIDS $!"

  # Lower the backdrop below all windows
  while ! xdo id -a "bar-backdrop" &>/dev/null; do sleep 0.1; done
  xdo id -a "bar-backdrop" | while read id; do
    xdo lower "$id"
  done
fi

# Main bar
"${DIR}/bars/main.sh" \
  | lemonbar \
  -g "${SCREEN_WIDTH}x$((HEIGHT - 1))" \
  "$(if [[ "$POSITION" == "bottom" ]]; then echo -ne "-b"; fi)" \
  -F "$TEXT_COLOR" \
  -f "$MAIN_FONT" \
  -B "$BACKGROUND_COLOR" \
  -f "Font Awesome 5 Free-Regular-10" \
  -o "$TEXT_OFFSET" \
  &
PIDS="$PIDS $!"

# Wait for those pids
wait $PIDS
