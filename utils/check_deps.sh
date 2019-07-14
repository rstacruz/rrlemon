warn() {
  local msg="$1"
  echo "$msg"

  if command -v "notify-send" &>/dev/null; then
    notify-send "rrlemon" "$msg"
  fi
}

if ! command -v i3-msg &>/dev/null; then
  warn 'i3-msg not found. rrlemon requires i3.'
  exit 1
fi

if ! command -v acpi &>/dev/null; then
  warn 'acpi not found. acpi is required to get battery status.'
  exit 1
fi

if ! command -v xdo &>/dev/null; then
  warn 'xdo not found. xdo is required to manipulate windows.'
  exit 1
fi
