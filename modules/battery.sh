battery() {
  if ! test -d /sys/class/power_supply/BAT0; then
    echo -ne "-"
    return
  fi

  # battery percent ('85%')
  local percent="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)%"

  # If connected ('1' or '0')
  # AC or ADP1
  local adapter="$(cat /sys/class/power_supply/A*/online 2>/dev/null)"

  # Discharging
  local status="$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)"

  # "Battery 0: Discharging, 86%, 03:18:06 remaining"
  local batinfo="$( \
    acpi --battery \
      | grep 'Battery 0' \
      | head -n 1 \
  )"

  # 03:14:28
  local time="$(echo "$batinfo" | cut -d' ' -f5 | cut -d':' -f1-2 | sed -s 's/^0//')"

  local suffix="$(if [[ "$status" == "Discharging" ]]; then echo "left"; else echo "to full"; fi)"

  if [[ "$percent" == "100%" ]]; then
    echo -ne "${MUTE}${percent}"
  else
    echo -ne "${MUTE}${time} ${suffix}${SPACE}${percent}"
  fi
}

while true; do
  cache:push BATTERY "$(battery)"
  sleep 20
done
