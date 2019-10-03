PIP_INACTIVE="●"
PIP_ACTIVE="●"

i3spaces_names() {
  local workspaces="$( \
    i3-msg -t get_workspaces \
    | "$DIR/vendor/json.sh" -b \
    | egrep '^\[[0-9]+,"(name|focused)"\]' \
    )"

  echo "$workspaces" | while read space; do
    read focused

    # Strip until the first tab
    # `[0,"name"]   "hello"` > `"hello"`
    local space="${space#*$'\t'}"
    local focused="${focused#*$'\t'}"

    # Remove prefix and quotes '"1:Term"' > 'Term'
    space="${space#*:}"
    space="${space/\"/}"
    space="${space/\"/}"

    if [[ "$focused" == "true" ]]; then echo -ne "$HILITE"; else echo -ne "$MUTE"; fi
    echo -ne "${space}$RESET$SPACE2"
  done
}

i3spaces_pips() {
  local workspaces="$( \
    i3-msg -t get_workspaces \
    | "$DIR/vendor/json.sh" -b \
    | egrep '^\[[0-9]+,"(num|focused)"\]' \
    )"

  echo "$workspaces" | while read num; do
    read focused
    local focused="${focused#*$'\t'}"

    if [[ "$focused" == "true" ]]; then
      echo -ne "$HILITE"
      echo -ne "${PIP_ACTIVE}$RESET$SPACE2"
    else
      echo -ne "$MUTE"
      echo -ne "${PIP_INACTIVE}$RESET$SPACE2"
    fi
  done
}

i3spaces() {
  case "$I3SPACES_MODE" in
    pips)
      i3spaces_pips
      ;;
    *)
      i3spaces_names
      ;;
  esac
}

cache:push I3SPACES "$(i3spaces)"

(
  set +e
  while true; do i3-msg -t subscribe -m '[ "workspace" ]'; done
) | while read output; do
  cache:push I3SPACES "$(i3spaces)"
done
