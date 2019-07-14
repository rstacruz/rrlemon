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
  title="${title:1}"
  title="${title:0:$((${#title} - 1))}"
  echo $title
}

(
  set +e
  while true; do i3-msg -t subscribe -m '[ "window" ]'; done
) | while read output; do
  cache:push I3WINDOW "$(i3window "$output")"
done
