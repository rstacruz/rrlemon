if command -v xdo &>/dev/null; then
  get_i3lock_status() {
    if pgrep "i3lock" &>/dev/null; then
      echo "Locked"
    else
      echo ''
    fi
  }

  while true; do
    cache:push I3LOCK "$(get_i3lock_status)"
    sleep 1
  done

  # todo: you can wait for it via 'xdo id -a i3lock -m'
fi
