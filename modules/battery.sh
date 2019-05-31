battery() {
  # 85%
  local percent="$(cat /sys/class/power_supply/BAT0/capacity)%"

  # Discharging
  local status="$(cat /sys/class/power_supply/BAT0/status)"

  # "Battery 0: Discharging, 86%, 03:18:06 remaining"
  local batinfo="$( \
    acpi --battery \
      | grep 'Battery 0' \
      | head -n 1 \
  )"

  # 03:14:28
  local time="$(echo "$batinfo" | cut -d' ' -f5 | cut -d':' -f1-2 | sed -s 's/^0//')"

  local suffix="$(if [[ "$status" == "Discharging" ]]; then echo "left"; else echo "to full"; fi)"

  echo -ne "${MUTE}${time} ${suffix}${SPACE}${percent}"
}

while true; do
  cache:push BATTERY "$(battery)"
  sleep 20
done
