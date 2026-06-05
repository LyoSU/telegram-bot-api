#!/bin/sh
set -e

# When started as root (the default), make the data volume writable for the
# unprivileged user and drop privileges. Some volume backends initialize the
# volume root as root-owned regardless of the image directory's owner.
if [ "$(id -u)" = "0" ]; then
    chown 10000:10000 /data 2>/dev/null || true
    exec setpriv --reuid=10000 --regid=10000 --clear-groups /usr/local/bin/telegram-bot-api "$@"
fi

exec /usr/local/bin/telegram-bot-api "$@"
