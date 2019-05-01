i3spaces:jq() {
  local workspaces="$(i3-msg -t get_workspaces)"
  local spaces="$(echo "$workspaces" | jq -r '.[] | .name, .focused')"

  echo "$spaces" | (
    while read space; do
      read focused
      if [[ "$focused" == "true" ]]; then echo -ne "$HILITE"; else echo -ne "$MUTE"; fi
      # Remove prefix '1:Term' > 'Term'
      local name="$(echo "$space" | sed 's/^[^:]\+://')"
      echo -ne "${name}$RESET$SPACE2"
    done
  )
}

i3spaces() {
  local workspaces="$( \
    i3-msg -t get_workspaces \
    | "$DIR/vendor/json.sh" \
    | egrep '^\[[0-9]+,"(name|focused)"\]' \
    )"

  echo "$workspaces" | (
    while read space; do
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
  )
}

i3-msg -t subscribe -m '[ "workspace" ]' | while read output; do
  cache:push I3SPACES "$(i3spaces)"
done &

cache:push I3SPACES "$(i3spaces)" &

