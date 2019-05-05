if command -v xdo &>/dev/null; then
  while xdo id -a i3lock -m &>/dev/null; do
    cache:push I3LOCK "Locked"

    while pgrep "i3lock" &>/dev/null; do
      sleep 0.2
    done

    cache:push I3LOCK ""
  done
fi
