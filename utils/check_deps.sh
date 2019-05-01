if ! command -v i3-msg &>/dev/null; then
  echo 'i3-msg not found'
  exit 1
fi
if ! command -v acpi &>/dev/null; then
  echo 'acpi not found'
  exit 1
fi
