#!/bin/sh
# Waits until a container has finished starting, so the first command you run in the dev container works.
# Gives up after START_LIMIT (e.g. 8m or 90s, set once in compose.yaml), so a broken startup is reported instead of
# being waited on forever. See "If the app won't start" in the README.
#
# Usage: wait-for-app.sh <service> <what> <command that succeeds once it's ready...>
service=$1 what=$2
shift 2
limit=${START_LIMIT:-5m}
# Whole hours, minutes and seconds, such as 1m30s; compose accepts other durations, but these cover any sensible limit
seconds=$(echo "$limit" | awk '{
  while (match($0, /^[0-9]+[hms]/)) {
    unit = substr($0, RLENGTH, 1)
    total += substr($0, 1, RLENGTH - 1) * (unit == "h" ? 3600 : unit == "m" ? 60 : 1)
    $0 = substr($0, RLENGTH + 1)
  }
  if ($0 != "" || total == "") exit 1
  print total
}') || { echo "START_LIMIT=$limit isn't a duration this script understands, such as 8m or 1m30s" >&2; exit 1; }
deadline=$(($(date +%s) + seconds))
until "$@" >/dev/null 2>&1; do
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "Gave up waiting for $what after $limit: see make logs SERVICE=$service, and \"If the app won't start\" in the README" >&2
    exit 1
  fi
  echo "Waiting for $what (rechecking in 5 seconds, will give up after $limit), see make logs SERVICE=$service"
  sleep 5
done
