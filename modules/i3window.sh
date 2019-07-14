i3window() {
  local output="$1"

  local raw="$(
    echo $output \
    | "${DIR:-.}/vendor/json.sh" -b \
    | egrep '^\["container","window_properties","title"\]' \
    )"

  # in: ["container","window_properties","title"]\t"hello world"
  # out: "hello world" (with quotes)
  local title="${raw#*$'\t'}"

  # Remove first and last characters
  if [[ "${title:0:1}" == '"' ]]; then
    title="${title:1}"
    title="${title:0:$((${#title} - 1))}"
  fi

  echo $title
}

# Initially, populate it with something, because we don't get
# new window data until something has changed
cache:push I3WINDOW "$(hostname)"

(
  set +e
  while true; do i3-msg -t subscribe -m '[ "window" ]'; done
) | while read output; do
  cache:push I3WINDOW "$(i3window "$output")"
done
