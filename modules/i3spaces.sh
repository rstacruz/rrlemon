i3spaces() {
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

i3-msg -t subscribe -m '[ "workspace" ]' | while read output; do
  cache:push I3SPACES "$(i3spaces)"
done &

cache:push I3SPACES "$(i3spaces)" &

