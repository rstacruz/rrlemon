# xdo takes too much resources. weird.
# if command -v xdo &>/dev/null; then
#   while xdo id -a i3lock -m &>/dev/null; do
#     cache:push I3LOCK "Locked"

#     while pgrep "i3lock" &>/dev/null; do
#       sleep 0.2
#     done

#     cache:push I3LOCK ""
#   done
# fi

if command -v pgrep &>/dev/null; then
  LAST_UNLOCKED=0

  while true; do
    pgrep i3lock &>/dev/null
    IS_UNLOCKED=$?

    if [[ "$IS_UNLOCKED" == "0" && "$LAST_UNLOCKED" != "0" ]]; then
      LAST_UNLOCKED="0"
      cache:push I3LOCK "Locked"
    fi

    if [[ "$IS_UNLOCKED" != "0" && "$LAST_UNLOCKED" == "0" ]]; then
      LAST_UNLOCKED="1"
      cache:push I3LOCK ""
    fi

    sleep 1
  done
fi
