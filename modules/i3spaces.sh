i3spaces() {
  local workspaces="$(i3-msg -t get_workspaces)"
  local spaces="$(echo "$workspaces" | jq -r '.[].name')"
  local focused="$(echo "$workspaces" | jq -r '.[] | select(.focused).name')"

  echo "$spaces" | while read space; do
    if [[ "$focused" == "$space" ]]; then echo -ne "$C"; else echo -ne "$M"; fi
    # Remove prefix '1:Term' > 'Term'
    local name="$(echo "$space" | sed 's/^[^:]\+://')"
    echo -ne "${name}$SS"
  done
}

