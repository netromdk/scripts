#!/bin/sh
# Script for using offlineimap that respects if enabled or not before actually
# synchronizing.

PROG="/opt/local/bin/offlineimap"
FILE="${HOME}/.offlineimap_disable"
LOG="${HOME}/.offlineimap.log"
UI="quiet" # "basic" to see some output.
SYNC="${PROG} -u ${UI} -o"
QUICK="${SYNC} -q"

if [ ! $# -eq 1 ]; then
  echo "Usage: $0 <command>"
  echo "Commands:"
  echo "  sync      Syncs IMAP."
  echo "  quick     Syncs IMAP quick (no flag updates)."
  echo "  enable    Enables syncing."
  echo "  disable   Disables syncing."
  echo "  status    If enabled or not."
  exit 1
fi

CMD=$1

check() {
  if [ -f ${FILE} ]; then
    echo "[$(date)] Aborting.. Syncing disabled.\n" >> ${LOG}
    exit 2
  fi
}

killExisting() {
  ps awux | grep ${PROG} | awk '{print $2;}' | xargs kill -9 &>/dev/null
}

pre() {
  echo "[$(date)] Started.." >> ${LOG}
}

post() {
  if [ $? -eq 0 ]; then
    echo "Status: Success" >> ${LOG}
  else
    echo "Status: Failed" >> ${LOG}
  fi
  echo "[$(date)] Finished..\n" >> ${LOG}
}

case $CMD in
  "sync")
    check
    killExisting
    pre
    ${SYNC}
    post
    ;;

  "quick")
    check
    killExisting
    pre
    ${QUICK}
    post
    ;;

  "enable")
    rm -f ${FILE}
    ;;

  "disable")
    touch ${FILE}
    ;;

  "status")
    if [ -f ${FILE} ]; then
      echo "Disabled"
    else
      echo "Enabled"
    fi
    ;;
esac
